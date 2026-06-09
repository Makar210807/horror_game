#ifndef MENU_CONTROLLER_H
#define MENU_CONTROLLER_H

#include <godot_cpp/classes/control.hpp>
#include <godot_cpp/classes/button.hpp>
#include <godot_cpp/classes/h_slider.hpp>
#include <godot_cpp/classes/v_box_container.hpp>
#include <godot_cpp/classes/h_box_container.hpp>
#include <godot_cpp/classes/label.hpp>
#include <godot_cpp/classes/panel.hpp>

namespace godot {

class MenuController : public Control {
    GDCLASS(MenuController, Control)

private:
    Button* play_button;
    Button* options_button;
    Button* quit_button;
    
    // Окно настроек и его элементы
    Panel* settings_popup;
    HSlider* music_slider;
    HSlider* mouse_slider;
    Button* close_button;
    
    void create_settings_popup();
    void hide_settings_popup();

protected:
    static void _bind_methods();

public:
    MenuController();
    ~MenuController();
    
    void _ready() override;
    void _on_play_pressed();
    void _on_options_pressed();
    void _on_quit_pressed();
    
    // Обработчики для настроек
    void _on_music_changed(double value);
    void _on_mouse_changed(double value);
    void _on_close_pressed();
};

}

#endif