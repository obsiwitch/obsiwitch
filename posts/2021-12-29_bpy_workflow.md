# Blender scripting workflow

## Configuration

### userprefs.py

I'm handling Blender's configuration in my [dotfiles](https://github.com/obsiwitch/dotfiles) with the `userprefs.py` ([59a22a9188](https://github.com/obsiwitch/dotfiles/blob/59a22a918833120496876dfe36a1fbffd331935f/user/blender/userprefs.py) | [HEAD](https://github.com/obsiwitch/dotfiles/blob/main/user/blender/userprefs.py)) script. The hashbang runs the script in blender with factory settings. First, the default scene (default cube, camera and light) is saved as the `startup.blend` file. Then, the preferences (e.g. ui scale, keybindings, enabling addons) are set. Finally, `userpref.blend` is saved and blender's window is closed.

### blenderimport

The `blenderimport` script ([59a22a9188](https://github.com/obsiwitch/dotfiles/blob/59a22a918833120496876dfe36a1fbffd331935f/user/bin/blenderimport) | [HEAD](https://github.com/obsiwitch/dotfiles/blob/main/user/bin/blenderimport)) allows me to quickly open 3D models (e.g. dae, stl, obj, gltf). It also allows me to open python scripts directly in Blender's scripting workspace.

The way the script is invoked is a bit tricky. `blender --python foo.py -- arg1 arg2 arg3` runs the `foo.py` python script in blender and passes the `arg1 arg2 arg3` arguments to the script. I can't simply use `#!/usr/bin/env -S blender --python` as the hashbang because it would be equivalent to calling `blender --python blenderimport arg1 arg2 arg3`; the `--` required to delimit the script arguments would be missing and the first script argument would be interpreted as a blend file, causing an error. To bypass this limit the hashbang calls python3. The script correctly formats the blender command and launches it with `os.execlp`. Then the second part of the script is executed inside blender and calls the correct importer(s) depending on which input file(s) have been provided.

The `blenderimport.desktop` ([59a22a9188](https://github.com/obsiwitch/dotfiles/blob/59a22a918833120496876dfe36a1fbffd331935f/user/blender/blenderimport.desktop) | [HEAD](https://github.com/obsiwitch/dotfiles/blob/main/user/blender/blenderimport.desktop)) desktop entry allows me to associate 3D model formats to the `blenderimport` script in the file manager.

### script_utils

`obsi_script_utils.py` ([59a22a9188](https://github.com/obsiwitch/dotfiles/blob/59a22a918833120496876dfe36a1fbffd331935f/user/blender/scripts/addons/obsi_script_utils.py) | [HEAD](https://github.com/obsiwitch/dotfiles/blob/main/user/blender/scripts/addons/obsi_script_utils.py)) is a Blender addon containing small scripting helpers.

* `bpy.types.Mesh.__repr__` monkey patch: dump the vertices, edges and faces of a mesh directly in Blender's python console.
```py
>>> D.meshes['Cube']
#~ bpy.data.meshes['Cube']
#~ vertices=[(1.0, 1.0, 1.0), (1.0, 1.0, -1.0), (1.0, -1.0, 1.0), (1.0, -1.0, -1.0), (-1.0, 1.0, 1.0), (-1.0, 1.0, -1.0), (-1.0, -1.0, 1.0), (-1.0, -1.0, -1.0)]
#~ edges=[(5, 7), (1, 5), (0, 1), (7, 6), (2, 3), (4, 5), (2, 6), (0, 2), (7, 3), (6, 4), (4, 0), (3, 1)]
#~ faces=[(0, 4, 6, 2), (3, 2, 6, 7), (7, 6, 4, 5), (5, 1, 3, 7), (1, 0, 2, 3), (5, 4, 0, 1)]
```
* `ScriptReloadRun`: reload and run the script currently opened in the text editor of the Scripting workspace from anywhere.
* `PrintContext`: dump the current context to stdout.


## Documentation

I've set up 2 keyword bookmarks in Firefox to quickly search the Python documentation and the Blender Python API documentation.

* **Python 3 Documentation**: `!py`, `https://docs.python.org/3/search.html?q=%s&check_keywords=yes&area=default`
* **Blender Python API documentation**: `!bpy`, `https://docs.blender.org/api/current/search.html?check_keywords=yes&area=default&q=%s`

## Scripting

* I'm not really confident about the code quality but you might find some useful snippets in my [scripts](https://github.com/obsiwitch/graphics/tree/main/BPY).
* [BPY Tips and Tricks - Executing Modules](https://docs.blender.org/api/current/info_tips_and_tricks.html#executing-modules)
* I call the `shared.delete_data()` function at the beginning of each of my scripts to guarantee it will always produce the same result after multiple executions (idempotency).
```py
def delete_data():
    for prop_collection in (
        bpy.data.actions, bpy.data.armatures, bpy.data.cameras,
        bpy.data.lights, bpy.data.materials, bpy.data.meshes,
        bpy.data.objects, bpy.data.collections, bpy.data.images
    ):
        for item in prop_collection:
            prop_collection.remove(item)
```
