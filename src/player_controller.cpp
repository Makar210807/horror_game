#include "player_controller.h"
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/classes/input.hpp>
#include <godot_cpp/classes/input_event_mouse_motion.hpp>
#include <godot_cpp/classes/input_event_key.hpp>
#include <godot_cpp/classes/camera3d.hpp>
#include <godot_cpp/classes/scene_tree.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include <algorithm>
#include <godot_cpp/classes/ray_cast3d.hpp>
#include <godot_cpp/classes/resource_loader.hpp>
#include <godot_cpp/classes/window.hpp>

namespace godot {

void PlayerController::_bind_methods() {
    ClassDB::bind_method(D_METHOD("set_can_move", "p_value"), &PlayerController::set_can_move);
    ClassDB::bind_method(D_METHOD("get_can_move"), &PlayerController::get_can_move);
    ClassDB::bind_method(D_METHOD("set_speed", "p_speed"), &PlayerController::set_speed);
    ClassDB::bind_method(D_METHOD("get_speed"), &PlayerController::get_speed);
	ClassDB::bind_method(D_METHOD("set_washed", "p_washed"), &PlayerController::set_washed);
    ClassDB::bind_method(D_METHOD("get_washed"), &PlayerController::get_washed);
    ClassDB::bind_method(D_METHOD("set_eaten", "p_eaten"), &PlayerController::set_eaten);
    ClassDB::bind_method(D_METHOD("get_eaten"), &PlayerController::get_eaten);
    ClassDB::bind_method(D_METHOD("set_has_energy_drink", "p_has"), &PlayerController::set_has_energy_drink);
    ClassDB::bind_method(D_METHOD("get_has_energy_drink"), &PlayerController::get_has_energy_drink);
    ClassDB::bind_method(D_METHOD("set_has_paid", "p_paid"), &PlayerController::set_has_paid);
    ClassDB::bind_method(D_METHOD("get_has_paid"), &PlayerController::get_has_paid);
    ClassDB::bind_method(D_METHOD("heal", "amount"), &PlayerController::heal);
    ClassDB::bind_method(D_METHOD("take_damage", "amount"), &PlayerController::take_damage);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "speed"), "set_speed", "get_speed");
}

PlayerController::PlayerController() {
    normal_speed = 5.0;
    run_speed = 8.0;
    mouse_sensitivity = 0.002;
    yaw = 0.0;
    pitch = 0.0;
    is_sprinting = false;
    is_crouching = false;
    was_c_key_pressed = false;
    camera_node = nullptr;
    footstep_sound = nullptr;
}
void PlayerController::set_washed(bool p_washed) { has_washed = p_washed; }
bool PlayerController::get_washed() const { return has_washed; }

void PlayerController::set_eaten(bool p_eaten) { has_eaten = p_eaten; }
bool PlayerController::get_eaten() const { return has_eaten; }

void PlayerController::set_has_energy_drink(bool p_has) { has_energy_drink = p_has; }
bool PlayerController::get_has_energy_drink() const { return has_energy_drink; }

void PlayerController::set_has_paid(bool p_paid) { has_paid = p_paid; }
bool PlayerController::get_has_paid() const { return has_paid; }

PlayerController::~PlayerController() {
}

void PlayerController::_ready() {
    UtilityFunctions::print("PlayerController ready!");
    
    add_to_group("player");
    UtilityFunctions::print("Player added to group 'player'");
    set_floor_max_angle(1);
    set_floor_snap_length(1);

    footstep_sound = get_node<AudioStreamPlayer3D>("FootstepSound");
    if (!footstep_sound) {
        UtilityFunctions::print("Warning: FootstepSound not found!");
    } else {
        UtilityFunctions::print("FootstepSound found");
    }

    for (int i = 0; i < get_child_count(); i++) {
        camera_node = dynamic_cast<Camera3D*>(get_child(i));
        if (camera_node) {
            UtilityFunctions::print("Camera found!");
            break;
        }
    }

    if (!camera_node) {
        UtilityFunctions::print("ERROR: Camera not found!");
    }

    if (!Engine::get_singleton()->is_editor_hint()) {
        Input::get_singleton()->set_mouse_mode(Input::MOUSE_MODE_CAPTURED);
        UtilityFunctions::print("Mouse captured!");
    }
    Node* spawn_marker = get_parent()->get_node_or_null("SpawnPoint");
    if (spawn_marker) {
        Node3D* marker = Object::cast_to<Node3D>(spawn_marker);
        if (marker) {
            // Устанавливаем позицию
            set_position(marker->get_position());
            // Устанавливаем поворот (взгляд)
            set_rotation(marker->get_rotation());
            UtilityFunctions::print("Spawn position: ", marker->get_position());
            UtilityFunctions::print("Spawn rotation: ", marker->get_rotation());
        }
    }
    yaw = get_rotation().y;  // Берём текущий поворот из редактора
    pitch = 0.0;
    
    UtilityFunctions::print("Initial yaw: ", yaw);
    UtilityFunctions::print("Initial rotation: ", get_rotation().y);
}

void PlayerController::_input(const Ref<InputEvent> &event) {
    Ref<InputEventMouseMotion> mouse_motion = event;
    if (mouse_motion.is_valid()) {
        Vector2 mouse_delta = mouse_motion->get_relative();

        yaw -= mouse_delta.x * mouse_sensitivity;
        pitch -= mouse_delta.y * mouse_sensitivity;
        pitch = std::clamp(pitch, -1.5, 1.5);

        set_rotation(Vector3(0, yaw, 0));

        if (camera_node) {
            camera_node->set_rotation(Vector3(pitch, 0, 0));
        }
    }

    Ref<InputEventKey> key_event = event;
    if (key_event.is_valid() && key_event->is_pressed()) {
        if (key_event->get_keycode() == Key::KEY_ESCAPE) {
            Input::get_singleton()->set_mouse_mode(Input::MOUSE_MODE_VISIBLE);
            get_tree()->quit();
            UtilityFunctions::print("Exiting game...");
            return;
        }
        if (key_event->get_keycode() == Key::KEY_F1) {
            Input::get_singleton()->set_mouse_mode(Input::MOUSE_MODE_CAPTURED);
            UtilityFunctions::print("Mouse captured forced!");
            return;
        }
        if (key_event->get_keycode() == Key::KEY_E) {
            UtilityFunctions::print("E key pressed!");
            try_interact();
        }
    }
}

void PlayerController::_physics_process(double delta) {
    if (!can_move) {
        set_velocity(Vector3(0, get_velocity().y, 0));
        move_and_slide();
        return;
}
    Input *input = Input::get_singleton();
    Vector3 velocity = get_velocity();

    Vector3 forward = Vector3(0, 0, -1).rotated(Vector3(0, 1, 0), yaw);
    Vector3 right = Vector3(1, 0, 0).rotated(Vector3(0, 1, 0), yaw);

    Vector3 move_direction = Vector3(0, 0, 0);
    if (input->is_key_pressed(Key::KEY_W)) move_direction += forward;
    if (input->is_key_pressed(Key::KEY_S)) move_direction -= forward;
    if (input->is_key_pressed(Key::KEY_A)) move_direction -= right;
    if (input->is_key_pressed(Key::KEY_D)) move_direction += right;

    move_direction = move_direction.normalized();

    is_sprinting = input->is_key_pressed(Key::KEY_SHIFT);
    double current_speed = normal_speed;
    if (is_sprinting && !is_crouching) {
        current_speed = run_speed;
    }

    velocity.x = move_direction.x * current_speed;
    velocity.z = move_direction.z * current_speed;

    set_velocity(velocity);
    move_and_slide();

    bool is_c_pressed = input->is_key_pressed(Key::KEY_C);
    if (is_c_pressed && !was_c_key_pressed) {
        set_crouch(!is_crouching);
    }
    was_c_key_pressed = is_c_pressed;

    bool is_moving = move_direction != Vector3(0, 0, 0);
    bool on_floor = is_on_floor();
    
    if (!is_moving) {
        if (footstep_sound && footstep_sound->is_playing()) {
            footstep_sound->stop();
        }
        footstep_timer = get_current_step_interval();
    }
    else if (on_floor && !is_crouching) {
        footstep_timer += delta;
        double current_interval = get_current_step_interval();
        if (footstep_timer >= current_interval) {
            footstep_timer = 0.0;
            play_footstep();
        }
    } else {
        footstep_timer = get_current_step_interval();
    }
}

void PlayerController::set_crouch(bool p_crouch) {
    is_crouching = p_crouch;

    if (is_crouching) {
        normal_speed = crouch_speed;
        if (camera_node) {
            camera_node->set_position(Vector3(0, crouch_height, 0));
        }
        UtilityFunctions::print("Crouching, speed: ", normal_speed);
    } else {
        normal_speed = 5.0;
        if (camera_node) {
            camera_node->set_position(Vector3(0, normal_height, 0));
        }
        UtilityFunctions::print("Standing up, speed: ", normal_speed);
    }
}

void PlayerController::set_speed(double p_speed) {
    normal_speed = p_speed;
}

double PlayerController::get_speed() const {
    return normal_speed;
}

void PlayerController::play_footstep() {
    if (!footstep_sound) return;
    
    if (current_footstep.is_null()) {
        current_footstep = ResourceLoader::get_singleton()->load("res://sounds/shagi_in_da_room.mp3");
        if (current_footstep.is_null()) {
            UtilityFunctions::print("Error: Failed to load footstep sound!");
            return;
        }
        footstep_sound->set_stream(current_footstep);
    }
    
    footstep_sound->play();
}

double PlayerController::get_current_step_interval() {
    if (is_sprinting && !is_crouching) {
        return sprint_step_interval;
    }
    return walk_step_interval;
}

void PlayerController::try_interact() {
    UtilityFunctions::print("try_interact called!");
    
    RayCast3D* ray = get_node<RayCast3D>("InteractRay");
    if (!ray) {
        UtilityFunctions::print("ERROR: InteractRay node not found! Add RayCast3D as child of PlayerController");
        return;
    }
    
    UtilityFunctions::print("RayCast found, checking collision...");
    
    if (ray->is_colliding()) {
        Object* hit_object = ray->get_collider();
        Node* hit = Object::cast_to<Node>(hit_object);
        
        if (hit) {
            UtilityFunctions::print("Hit object: ", hit->get_name());
            
            if (hit->has_method("interact")) {
                UtilityFunctions::print("Calling interact() on ", hit->get_name());
                hit->call("interact");
            } else {
                UtilityFunctions::print("Object ", hit->get_name(), " has no interact() method");
            }
        } else {
            UtilityFunctions::print("Failed to cast Object to Node");
        }
    } else {
        UtilityFunctions::print("No collision detected");
    }
}
void PlayerController::set_can_move(bool p_value) {
    can_move = p_value;
    UtilityFunctions::print("Can move: ", can_move ? "true" : "false");
}

bool PlayerController::get_can_move() const {
    return can_move;
}
void PlayerController::heal(float amount) {
    health += amount;
    if (health > 100.0) {
        health = 100.0;
    }
    UtilityFunctions::print("Player healed by ", amount, " Health: ", health);
}
    void PlayerController::take_damage(float amount) {
    UtilityFunctions::print("=== take_damage called ===");
    UtilityFunctions::print("Damage amount: ", amount);
    UtilityFunctions::print("Health before: ", health);

    health -= amount;
    UtilityFunctions::print("Health after: ", health);

    if (health <= 0) {
        UtilityFunctions::print("Player died! Respawning in shop...");

        // Ищем QuestData
        Node* quest_data = get_tree()->get_root()->find_child("QuestData", true, false);
        if (quest_data) {
            quest_data->call("set_killed_by_enemy", true);
            UtilityFunctions::print("Set killed_by_enemy flag");
        } else {
            UtilityFunctions::print("QuestData not found! Check Autoload");
        }

        // Восстанавливаем здоровье
        health = 100.0;

        // Переход в магазин
        get_tree()->change_scene_to_file("res://shop.tscn");
    }
}
} // namespace godot