import bpy
import json
from mathutils import Matrix

scene = bpy.context.scene
camera = scene.camera

if camera is None:
    raise RuntimeError("No active scene camera")
original_frame = scene.frame_current
original_subframe = scene.frame_subframe
data = {
    "fps": scene.render.fps / scene.render.fps_base,
    "frames": []
}

try:
    for frame in range(scene.frame_start, scene.frame_end + 1):
        scene.frame_set(frame)

        depsgraph = bpy.context.evaluated_depsgraph_get()
        cam = camera.evaluated_get(depsgraph)

        matrix = cam.matrix_world.copy()
        position = matrix.translation
        rotation = matrix.to_quaternion()
        camera_data = cam.data

        data["frames"].append({
            "frame": frame,
            "time": (
                (frame - scene.frame_start)
                / (scene.render.fps / scene.render.fps_base)
            ),
            "position": [
                position.x, position.y, position.z
            ],
            "rotation": [
                rotation.w, rotation.x,
                rotation.y, rotation.z
            ],
            "fov_x": camera_data.angle_x,
            "fov_y": camera_data.angle_y,
        })
finally:
    scene.frame_set(original_frame, subframe=original_subframe)

def lua_value(value):
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, (int, float)):
        # Lua accepts scientific notation. Ensure valid finite numbers.
        import math
        if not math.isfinite(value):
            raise ValueError(f"Non-finite Lua number: {value}")
        return repr(value)
    if isinstance(value, str):
        return '"' + (
            value.replace("\\", "\\\\")
                 .replace('"', '\\"')
                 .replace("\n", "\\n")
                 .replace("\r", "\\r")
        ) + '"'
    if isinstance(value, (list, tuple)):
        return "{" + ",".join(lua_value(v) for v in value) + "}"
    if isinstance(value, dict):
        return "{" + ",".join(
            "[" + lua_value(k) + "]=" + lua_value(v)
            for k, v in value.items()
        ) + "}"
    raise TypeError(f"Unsupported Lua value: {type(value).__name__}")


output_path = bpy.path.abspath("//camera_animation.lua")

with open(output_path, "w", encoding="utf-8", newline="\n") as f:
    f.write("return ")
    f.write(lua_value(data))
    f.write("\n")

print(f"Exported {len(data['frames'])} camera samples to {output_path}")
