#ifndef MENU_CONTROLLER_H
#define MENU_CONTROLLER_H

#include <godot_cpp/classes/control.hpp>
#include <godot_cpp/classes/button.hpp>

namespace godot {

class MenuController : public Control {
    GDCLASS(MenuController, Control)

private:
    Button* play_button;
    Button* options_button;
    Button* quit_button;

protected:
    static void _bind_methods();

public:
    MenuController();
    ~MenuController();
    
    void _ready() override;
    void _on_play_pressed();
    void _on_options_pressed();
    void _on_quit_pressed();
};

}

#endif
