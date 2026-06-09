#ifndef ENEMY_H
#define ENEMY_H

#include <godot_cpp/classes/character_body3d.hpp>
#include <godot_cpp/classes/node3d.hpp>
#include <godot_cpp/classes/window.hpp>

namespace godot {

class Enemy : public CharacterBody3D {
    GDCLASS(Enemy, CharacterBody3D)

protected:
    static void _bind_methods();

public:
    Enemy();
    ~Enemy();

    void _ready() override;
    void _physics_process(double delta) override;

    void set_speed(double p_speed);
    double get_speed() const;
    void take_damage(float amount);
    void set_health(float p_health);
    float get_health() const;

    void stop_chasing();
    void resume_chasing();

private:
    double speed = 3.0;
    float health = 100.0;
    double chase_range = 10.0;
    double stop_distance = 1.5;
    bool is_chasing = true;
    Node3D* player = nullptr;
};

} // namespace godot

#endif // ENEMY_H