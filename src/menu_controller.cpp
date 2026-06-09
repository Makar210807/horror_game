#include "menu_controller.h"
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/classes/input.hpp>
#include <godot_cpp/classes/scene_tree.hpp>
#include <godot_cpp/classes/resource_loader.hpp>
#include <godot_cpp/classes/style_box_flat.hpp>
#include <godot_cpp/classes/audio_stream_player.hpp>
#include <godot_cpp/classes/viewport.hpp>
#include <godot_cpp/classes/window.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include <cmath>

namespace godot {

void MenuController::_bind_methods() {
    ClassDB::bind_method(D_METHOD("_on_play_pressed"), &MenuController::_on_play_pressed);
    ClassDB::bind_method(D_METHOD("_on_options_pressed"), &MenuController::_on_options_pressed);
    ClassDB::bind_method(D_METHOD("_on_quit_pressed"), &MenuController::_on_quit_pressed);
    ClassDB::bind_method(D_METHOD("_on_music_changed", "value"), &MenuController::_on_music_changed);
    ClassDB::bind_method(D_METHOD("_on_mouse_changed", "value"), &MenuController::_on_mouse_changed);
    ClassDB::bind_method(D_METHOD("_on_close_pressed"), &MenuController::_on_close_pressed);
}

MenuController::MenuController() {
    play_button = nullptr;
    options_button = nullptr;
    quit_button = nullptr;
    settings_popup = nullptr;
    music_slider = nullptr;
    mouse_slider = nullptr;
    close_button = nullptr;
}

MenuController::~MenuController() {
}

void MenuController::_ready() {
    UtilityFunctions::print("MenuController ready!");
    
    play_button = get_node<Button>("VBoxContainer/PlayButton");
    options_button = get_node<Button>("VBoxContainer/OptionsButton");
    quit_button = get_node<Button>("VBoxContainer/QuitButton");
    
    if (play_button) {
        play_button->connect("pressed", Callable(this, "_on_play_pressed"));
    }
    if (options_button) {
        options_button->connect("pressed", Callable(this, "_on_options_pressed"));
    }
    if (quit_button) {
        quit_button->connect("pressed", Callable(this, "_on_quit_pressed"));
    }
    
    create_settings_popup();
    hide_settings_popup();
    
    Input::get_singleton()->set_mouse_mode(Input::MOUSE_MODE_VISIBLE);
}

void MenuController::create_settings_popup() {
    settings_popup = memnew(Panel);
    settings_popup->set_name("SettingsPopup");
    settings_popup->set_visible(false);
    
    // Размер окна под 320x240
    settings_popup->set_size(Vector2(280, 200));
    
    // Центрируем окно
    Vector2 screen_size = get_viewport()->get_visible_rect().size;
    Vector2 popup_size = settings_popup->get_size();
    Vector2 center_pos = (screen_size - popup_size) / 2;
    settings_popup->set_position(center_pos);
    
    Ref<StyleBoxFlat> panel_style = memnew(StyleBoxFlat);
    panel_style->set_bg_color(Color(0.12, 0.12, 0.12, 1.0));
    panel_style->set_border_width_all(2);
    panel_style->set_border_color(Color(0.4, 0.4, 0.4, 1.0));
    panel_style->set_corner_radius_all(5);
    settings_popup->add_theme_stylebox_override("panel", panel_style);
    
    VBoxContainer* content = memnew(VBoxContainer);
    content->set_name("Content");
    content->set_anchors_and_offsets_preset(Control::PRESET_FULL_RECT);
    content->add_theme_constant_override("separation", 8);
    settings_popup->add_child(content);
    
    // Заголовок
    Label* title = memnew(Label);
    title->set_text(String::utf8("Настройки"));
    title->set_horizontal_alignment(HORIZONTAL_ALIGNMENT_CENTER);
    title->add_theme_font_size_override("font_size", 20);
    title->add_theme_color_override("font_color", Color(1, 1, 1, 1));
    content->add_child(title);
    
    // Громкость
    HBoxContainer* music_row = memnew(HBoxContainer);
    music_row->set_h_size_flags(Control::SIZE_EXPAND);
    
    Label* music_label = memnew(Label);
    music_label->set_text(String::utf8("Громкость музыки:"));
    music_label->set_h_size_flags(Control::SIZE_EXPAND);
    music_label->add_theme_font_size_override("font_size", 12);
    music_row->add_child(music_label);
    
    music_slider = memnew(HSlider);
    music_slider->set_min(0);
    music_slider->set_max(100);
    music_slider->set_value(70);
    music_slider->set_h_size_flags(Control::SIZE_SHRINK_CENTER);
    music_slider->set_custom_minimum_size(Vector2(120, 0));
    music_slider->connect("value_changed", Callable(this, "_on_music_changed"));
    music_row->add_child(music_slider);
    content->add_child(music_row);
    
    // Чувствительность мыши
    HBoxContainer* mouse_row = memnew(HBoxContainer);
    mouse_row->set_h_size_flags(Control::SIZE_EXPAND);
    
    Label* mouse_label = memnew(Label);
    mouse_label->set_text(String::utf8("Чувствительность мыши:"));
    mouse_label->set_h_size_flags(Control::SIZE_EXPAND);
    mouse_label->add_theme_font_size_override("font_size", 12);
    mouse_row->add_child(mouse_label);
    
    mouse_slider = memnew(HSlider);
    mouse_slider->set_min(0);
    mouse_slider->set_max(2);
    mouse_slider->set_step(0.01);
    mouse_slider->set_value(0.01);
    mouse_slider->set_h_size_flags(Control::SIZE_SHRINK_CENTER);
    mouse_slider->set_custom_minimum_size(Vector2(120, 0));
    mouse_slider->connect("value_changed", Callable(this, "_on_mouse_changed"));
    mouse_row->add_child(mouse_slider);
    content->add_child(mouse_row);
    
    // Кнопка закрытия
    close_button = memnew(Button);
    close_button->set_text(String::utf8("Назад"));
    close_button->set_h_size_flags(Control::SIZE_SHRINK_CENTER);
    close_button->add_theme_font_size_override("font_size", 12);
    close_button->connect("pressed", Callable(this, "_on_close_pressed"));
    content->add_child(close_button);
    
    add_child(settings_popup);
}

void MenuController::hide_settings_popup() {
    if (settings_popup) {
        settings_popup->set_visible(false);
    }
}

void MenuController::_on_options_pressed() {
    UtilityFunctions::print("Options button pressed!");
    if (settings_popup) {
        settings_popup->set_visible(true);
    }
}

void MenuController::_on_music_changed(double value) {
    UtilityFunctions::print("Music volume changed to: ", value);
    
    // Ищем узел AudioStreamPlayer по всей сцене
    Node* music_player = get_tree()->get_root()->find_child("AudioStreamPlayer", true, false);
    
    if (music_player && music_player->has_method("set_volume_db")) {
        double linear = value / 100.0;
        double db = linear > 0 ? 20.0 * log10(linear) : -80.0;
        music_player->call("set_volume_db", db);
        UtilityFunctions::print("Music volume set to dB: ", db);
    } else {
        UtilityFunctions::print("AudioStreamPlayer not found!");
    }
}

void MenuController::_on_mouse_changed(double value) {
    UtilityFunctions::print("Mouse sensitivity changed to: ", value);
    
    // Сохраняем в глобальный синглтон (GDScript AutoLoad)
    Node* settings = get_node_or_null("/root/SettingsData");
    if (settings && settings->has_method("set_mouse_sensitivity")) {
        settings->call("set_mouse_sensitivity", value);
    }
    
    // Применяем к текущему игроку
    Array players = get_tree()->get_nodes_in_group("player");
    for (int i = 0; i < players.size(); i++) {
        Node* player = Object::cast_to<Node>(players[i]);
        if (player && player->has_method("set_mouse_sensitivity")) {
            player->call("set_mouse_sensitivity", value);
        }
    }
}

void MenuController::_on_close_pressed() {
    UtilityFunctions::print("Close button pressed!");
    hide_settings_popup();
}

void MenuController::_on_play_pressed() {
    UtilityFunctions::print("Play button pressed!");
    get_tree()->change_scene_to_file("res://house.tscn");
}

void MenuController::_on_quit_pressed() {
    UtilityFunctions::print("Quit button pressed!");
    get_tree()->quit();
}

}