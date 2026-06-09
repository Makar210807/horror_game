#include "menu_controller.h"
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/classes/input.hpp>
#include <godot_cpp/classes/scene_tree.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

namespace godot {

void MenuController::_bind_methods() {
    ClassDB::bind_method(D_METHOD("_on_play_pressed"), &MenuController::_on_play_pressed);
    ClassDB::bind_method(D_METHOD("_on_options_pressed"), &MenuController::_on_options_pressed);
    ClassDB::bind_method(D_METHOD("_on_quit_pressed"), &MenuController::_on_quit_pressed);
}

MenuController::MenuController() {
    play_button = nullptr;
    options_button = nullptr;
    quit_button = nullptr;
}

MenuController::~MenuController() {
}

void MenuController::_ready() {
    UtilityFunctions::print("MenuController готов!");
    
    // Находим кнопки в сцене
    play_button = get_node<Button>("VBoxContainer/PlayButton");
    options_button = get_node<Button>("VBoxContainer/OptionsButton");
    quit_button = get_node<Button>("VBoxContainer/QuitButton");
    
    // Подключаем сигналы
    if (play_button) {
        play_button->connect("pressed", Callable(this, "_on_play_pressed"));
    }
    if (options_button) {
        options_button->connect("pressed", Callable(this, "_on_options_pressed"));
    }
    if (quit_button) {
        quit_button->connect("pressed", Callable(this, "_on_quit_pressed"));
    }
    
    // Показываем курсор мыши
    Input::get_singleton()->set_mouse_mode(Input::MOUSE_MODE_VISIBLE);
}

void MenuController::_on_play_pressed() {
    UtilityFunctions::print("Нажата кнопка Play! Переход в игру...");
    get_tree()->change_scene_to_file("res://house.tscn");
}

void MenuController::_on_options_pressed() {
    UtilityFunctions::print("Нажата кнопка Options! Открытие настроек...");
    // TODO: позже создадим сцену настроек
    // get_tree()->change_scene_to_file("res://options.tscn");
}

void MenuController::_on_quit_pressed() {
    UtilityFunctions::print("Нажата кнопка Quit! Выход из игры...");
    get_tree()->quit();
}

}