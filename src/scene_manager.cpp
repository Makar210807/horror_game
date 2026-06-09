#include "scene_manager.h"
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/classes/scene_tree.hpp>
#include <godot_cpp/classes/resource_loader.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

namespace godot {

    void SceneManager::_bind_methods() {
        ClassDB::bind_method(D_METHOD("change_scene", "path"), &SceneManager::change_scene);
    }

    SceneManager::SceneManager() {
    }

    SceneManager::~SceneManager() {
    }

    void SceneManager::change_scene(const String& path) {
        UtilityFunctions::print("SceneManager: changing scene to ", path);

        if (path.is_empty()) {
            UtilityFunctions::print("SceneManager: path is empty!");
            return;
        }

        if (!ResourceLoader::get_singleton()->exists(path)) {
            UtilityFunctions::print("SceneManager: file not found - ", path);
            return;
        }

        get_tree()->change_scene_to_file(path);
    }

}