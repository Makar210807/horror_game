#ifndef PLAYER_CONTROLLER_H
#define PLAYER_CONTROLLER_H

#include <godot_cpp/classes/character_body3d.hpp>
#include <godot_cpp/classes/input_event.hpp>
#include <godot_cpp/classes/camera3d.hpp>
#include <godot_cpp/classes/resource_loader.hpp>
#include <godot_cpp/classes/audio_stream_player3d.hpp>
#include <godot_cpp/classes/audio_stream.hpp>

namespace godot {

class PlayerController : public CharacterBody3D {
    GDCLASS(PlayerController, CharacterBody3D)

protected:
    static void _bind_methods();

public:
    void set_can_move(bool p_value);
    bool get_can_move() const;
    PlayerController();
    ~PlayerController();

    void _ready() override;
    void _physics_process(double delta) override;
    void _input(const Ref<InputEvent> &event) override;
    void take_damage(float damage);
    void heal(float amount);

    void set_speed(double p_speed);
    double get_speed() const;
    void set_washed(bool p_washed);
    bool get_washed() const;
    void set_eaten(bool p_eaten);
    bool get_eaten() const;
    void set_has_energy_drink(bool p_has_energy_drink);
    bool get_has_energy_drink() const;
    void set_has_paid(bool p_has_paid);
    bool get_has_paid() const;

private:
    bool can_move = true;   
    void try_interact();
    
    AudioStreamPlayer3D* footstep_sound;
    Ref<AudioStream> current_footstep;

    double footstep_timer = 0.0;
    double walk_step_interval = 0.5;
    double sprint_step_interval = 0.35;
    
    double get_current_step_interval();
    void play_footstep();

    Camera3D* camera_node = nullptr;

    bool was_c_key_pressed = false;
    bool is_crouching = false;

    double normal_height = 1.8;
    double crouch_height = 1.0;
    double normal_speed = 5.0;
    double crouch_speed = 2.5;
    double run_speed = 8.0;
    double mouse_sensitivity = 0.002;
    double yaw = 0.0;
    double pitch = 0.0;
    double health = 0.0;
    bool is_sprinting = false;
    bool has_washed = false;
    bool has_eaten = false;
    bool has_energy_drink = false;
    bool has_paid = false;

    void set_crouch(bool p_crouch);
};

}

#endif