#ifndef SCENE_MANAGER_H
#define SCENE_MANAGER_H

#include <godot_cpp/classes/node.hpp>

namespace godot {

    class SceneManager : public Node {
        GDCLASS(SceneManager, Node)

    protected:
        static void _bind_methods();

    public:
        SceneManager();
        ~SceneManager();

        void change_scene(const String& path);
    };

}

#endif