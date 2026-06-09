#include "enemy.h"

#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/classes/scene_tree.hpp>
#include <godot_cpp/classes/node3d.hpp>
#include <godot_cpp/classes/character_body3d.hpp>
#include <godot_cpp/classes/window.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include <godot_cpp/variant/vector3.hpp>

namespace godot {

void Enemy::_bind_methods() {
    ClassDB::bind_method(D_METHOD("set_speed", "p_speed"), &Enemy::set_speed);
    ClassDB::bind_method(D_METHOD("get_speed"), &Enemy::get_speed);
    ClassDB::bind_method(D_METHOD("take_damage", "amount"), &Enemy::take_damage);
    ClassDB::bind_method(D_METHOD("set_health", "p_health"), &Enemy::set_health);
    ClassDB::bind_method(D_METHOD("get_health"), &Enemy::get_health);

    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "speed"), "set_speed", "get_speed");
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "health"), "set_health", "get_health");
}

Enemy::Enemy() {
    speed = 8.1;
    health = 100.0;
    stop_distance = 1.5;
    player = nullptr;
}

Enemy::~Enemy() {
}

void Enemy::_ready() {
    UtilityFunctions::print("Enemy готов!");

    Window* root = get_tree()->get_root();
    if (root) {
        player = dynamic_cast<Node3D*>(root->find_child("PlayerController", true, false));
        if (player) {
            UtilityFunctions::print("Enemy нашёл игрока!");
        } else {
            UtilityFunctions::print("Enemy не нашёл игрока!");
        }
    }
}

void Enemy::_physics_process(double delta) {
    if (player == nullptr) return;

    Vector3 velocity = get_velocity();

    // Гравитация
    if (!is_on_floor()) {
        velocity.y -= 9.8 * delta;
    } else {
        velocity.y = 0;
    }

    // Если скорость 0 - НИКАКОГО ДВИЖЕНИЯ
    if (speed <= 0.0) {
        velocity.x = 0;
        velocity.z = 0;
        set_velocity(velocity);
        move_and_slide();
        return;
    }

    double distance = get_position().distance_to(player->get_position());

    if (distance > stop_distance) {
        Vector3 direction = player->get_position() - get_position();
        direction.y = 0;

        if (direction.length() > 0.1) {
            direction = direction.normalized();

            float angle = atan2(direction.x, direction.z);
            set_rotation(Vector3(0, angle, 0));

            velocity.x = direction.x * speed;
            velocity.z = direction.z * speed;
        }
    } else {
        velocity.x = 0;
        velocity.z = 0;
    }

    set_velocity(velocity);
    move_and_slide();
}

void Enemy::take_damage(float amount) {
    health -= amount;
    UtilityFunctions::print("Enemy получил урон: ", amount, " Осталось здоровья: ", health);

    if (health <= 0) {
        UtilityFunctions::print("Enemy умер!");
        queue_free();
    }
}

void Enemy::set_speed(double p_speed) {
    speed = p_speed;
    UtilityFunctions::print("Скорость врага изменена на: ", speed);

    // Принудительная остановка
    if (speed <= 0.0) {
        set_velocity(Vector3(0, get_velocity().y, 0));
    }
}

double Enemy::get_speed() const {
    return speed;
}

void Enemy::set_health(float p_health) {
    health = p_health;
}

float Enemy::get_health() const {
    return health;
}

} // namespace godot