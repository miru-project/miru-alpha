#include "include/screen_brightness_linux/screen_brightness_linux_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <cstring>
#include <exception>
#include <iostream>
#include <X11/Xatom.h>
#include <X11/Xlib.h>
#include <X11/extensions/Xrandr.h>

// Forward declarations: the method-call dispatcher below invokes handlers
// that are defined further down in this file. Upstream (feature/linux_support)
// relies on definition order, which C++ does not allow, so the plugin failed
// to compile with "use of undeclared identifier" errors. These prototypes
// restore declaration-before-use without changing any behaviour.
static void screen_brightness_linux_plugin_handle_get_system_screen_brightness_method_call(
        ScreenBrightnessLinuxPlugin *self, FlMethodCall *method_call);
static void screen_brightness_linux_plugin_handle_set_system_screen_brightness_method_call(
        ScreenBrightnessLinuxPlugin *self, FlMethodCall *method_call);
static void screen_brightness_linux_plugin_handle_get_application_screen_brightness_method_call(
        ScreenBrightnessLinuxPlugin *self, FlMethodCall *method_call);
static void screen_brightness_linux_plugin_handle_set_application_screen_brightness_method_call(
        ScreenBrightnessLinuxPlugin *self, FlMethodCall *method_call);
static void screen_brightness_linux_plugin_handle_reset_application_screen_brightness_method_call(
        ScreenBrightnessLinuxPlugin *self, FlMethodCall *method_call);
static void screen_brightness_linux_plugin_handle_has_application_screen_brightness_changed_method_call(
        ScreenBrightnessLinuxPlugin *self, FlMethodCall *method_call);
static void screen_brightness_linux_plugin_handle_is_auto_reset_method_call(
        ScreenBrightnessLinuxPlugin *self, FlMethodCall *method_call);
static void screen_brightness_linux_plugin_handle_set_auto_reset_method_call(
        ScreenBrightnessLinuxPlugin *self, FlMethodCall *method_call);
static void screen_brightness_linux_plugin_handle_is_animate_method_call(
        ScreenBrightnessLinuxPlugin *self, FlMethodCall *method_call);
static void screen_brightness_linux_plugin_handle_set_animate_method_call(
        ScreenBrightnessLinuxPlugin *self, FlMethodCall *method_call);
static void screen_brightness_linux_plugin_handle_can_change_system_brightness_method_call(
        ScreenBrightnessLinuxPlugin *self, FlMethodCall *method_call);

#define SCREEN_BRIGHTNESS_LINUX_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), screen_brightness_linux_plugin_get_type(), \
                              ScreenBrightnessLinuxPlugin))

struct _ScreenBrightnessLinuxPlugin {
    GObject parent_instance;

    FlPluginRegistrar *registrar = nullptr;

    FlMethodChannel *method_channel = nullptr;

    FlEventChannel *system_screen_brightness_changed_event_channel = nullptr;

    FlEventChannel *application_screen_brightness_changed_event_channel = nullptr;

    gdouble system_brightness_ = -1;

    gdouble application_brightness_ = -1;

    gdouble minimum_brightness_ = -1;

    gdouble maximum_brightness_ = -1;

    gboolean is_auto_reset_ = true;

    gboolean is_animate_ = true;

    GtkWidget *toplevel_window = nullptr;

    guint is_active_handler_id = 0;

    guint window_state_handler_id = 0;
};

G_DEFINE_TYPE(ScreenBrightnessLinuxPlugin, screen_brightness_linux_plugin, g_object_get_type()
)

// Called when a method call is received from Flutter.
static void screen_brightness_linux_plugin_handle_method_call(
        ScreenBrightnessLinuxPlugin *self,
        FlMethodCall *method_call) {
    const gchar *method = fl_method_call_get_name(method_call);

    if (strcmp(method, "getSystemScreenBrightness") == 0) {
        screen_brightness_linux_plugin_handle_get_system_screen_brightness_method_call(self,
                                                                                        method_call);
        return;
    }

    if (strcmp(method, "setSystemScreenBrightness") == 0) {
        screen_brightness_linux_plugin_handle_set_system_screen_brightness_method_call(self,
                                                                                        method_call);
        return;
    }

    if (strcmp(method, "getApplicationScreenBrightness") == 0) {
        screen_brightness_linux_plugin_handle_get_application_screen_brightness_method_call(self,
                                                                                             method_call);
        return;
    }

    if (strcmp(method, "setApplicationScreenBrightness") == 0) {
        screen_brightness_linux_plugin_handle_set_application_screen_brightness_method_call(self,
                                                                                             method_call);
        return;
    }

    if (strcmp(method, "resetApplicationScreenBrightness") == 0) {
        screen_brightness_linux_plugin_handle_reset_application_screen_brightness_method_call(self,
                                                                                               method_call);
        return;
    }

    if (strcmp(method, "hasApplicationScreenBrightnessChanged") == 0) {
        screen_brightness_linux_plugin_handle_has_application_screen_brightness_changed_method_call(
                self, method_call);
        return;
    }

    if (strcmp(method, "isAutoReset") == 0) {
        screen_brightness_linux_plugin_handle_is_auto_reset_method_call(self, method_call);
        return;
    }

    if (strcmp(method, "setAutoReset") == 0) {
        screen_brightness_linux_plugin_handle_set_auto_reset_method_call(self, method_call);
        return;
    }

    if (strcmp(method, "isAnimate") == 0) {
        screen_brightness_linux_plugin_handle_is_animate_method_call(self, method_call);
        return;
    }

    if (strcmp(method, "setAnimate") == 0) {
        screen_brightness_linux_plugin_handle_set_animate_method_call(self, method_call);
        return;
    }

    if (strcmp(method, "canChangeSystemBrightness") == 0) {
        screen_brightness_linux_plugin_handle_can_change_system_brightness_method_call(self,
                                                                                        method_call);
        return;
    }

    // Backward compatibility aliases
    if (strcmp(method, "getScreenBrightness") == 0) {
        screen_brightness_linux_plugin_handle_get_application_screen_brightness_method_call(self,
                                                                                             method_call);
        return;
    }

    if (strcmp(method, "setScreenBrightness") == 0) {
        screen_brightness_linux_plugin_handle_set_application_screen_brightness_method_call(self,
                                                                                             method_call);
        return;
    }

    if (strcmp(method, "resetScreenBrightness") == 0) {
        screen_brightness_linux_plugin_handle_reset_application_screen_brightness_method_call(self,
                                                                                               method_call);
        return;
    }

    if (strcmp(method, "hasChanged") == 0) {
        screen_brightness_linux_plugin_handle_has_application_screen_brightness_changed_method_call(
                self, method_call);
        return;
    }

    fl_method_call_respond(method_call, FL_METHOD_RESPONSE(fl_method_not_implemented_response_new()),
                           nullptr);
}

static void screen_brightness_linux_plugin_get_brightness(double &minimum_brightness,
                                                          double &maximum_brightness,
                                                          double &current_brightness) {
    try {
        Display *display = XOpenDisplay(nullptr);
        if (display == nullptr) return;

        Atom backlight = XInternAtom(display, "Backlight", True);
        if (backlight == None) {
            XCloseDisplay(display);
            return;
        }

        Window root = RootWindow(display, 0);
        XRRScreenResources *resources = XRRGetScreenResources(display, root);
        if (resources == nullptr) {
            XCloseDisplay(display);
            return;
        }

        RROutput output = resources->outputs[0];
        XRRPropertyInfo *info = XRRQueryOutputProperty(display, output, backlight);
        if (info != nullptr) {
            if (info->num_values >= 2) {
                minimum_brightness = info->values[0];
                maximum_brightness = info->values[1];
            }
            XFree(info);
        }

        // Get current brightness value
        Atom actual_type;
        int actual_format;
        unsigned long nitems, bytes_after;
        long *prop = nullptr;
        XRRGetOutputProperty(display, output, backlight, 0, 4, False, False,
                             AnyPropertyType, &actual_type, &actual_format,
                             &nitems, &bytes_after, (unsigned char **) &prop);
        if (prop != nullptr) {
            if (nitems > 0) {
                current_brightness = prop[0];
            }
            XFree(prop);
        }

        XRRFreeScreenResources(resources);
        XCloseDisplay(display);
    } catch (const std::exception &exception) {
        std::cout << exception.what() << std::endl;
    }
}

static void screen_brightness_linux_plugin_set_brightness(double brightness) {
    try {
        double min = 0;
        double max = 0;

        Display *display = XOpenDisplay(nullptr);
        if (display == nullptr) return;

        Atom backlight = XInternAtom(display, "Backlight", True);
        if (backlight == None) {
            XCloseDisplay(display);
            return;
        }

        Window root = RootWindow(display, 0);
        XRRScreenResources *resources = XRRGetScreenResources(display, root);
        if (resources == nullptr) {
            XCloseDisplay(display);
            return;
        }

        RROutput output = resources->outputs[0];
        XRRPropertyInfo *info = XRRQueryOutputProperty(display, output, backlight);
        if (info != nullptr) {
            if (info->num_values >= 2) {
                min = info->values[0];
                max = info->values[1];
            }
            XFree(info);
        }
        XRRFreeScreenResources(resources);

        if (min == max) {
            XCloseDisplay(display);
            return;
        }

        double value = brightness * (max - min) + min;

        XRRChangeOutputProperty(display, output, backlight, XA_INTEGER,
                                32, PropModeReplace, (unsigned char *) &value, 1);
        XFlush(display);
        XSync(display, False);
        XCloseDisplay(display);
    } catch (const std::exception &exception) {
        std::cout << exception.what() << std::endl;
    }
}

static double
screen_brightness_linux_plugin_get_brightness_percentage(double minimum_brightness,
                                                           double maximum_brightness,
                                                           double brightness) {
    if (maximum_brightness == minimum_brightness) {
        return 0;
    }
    return (brightness - minimum_brightness) / (maximum_brightness - minimum_brightness);
}

static void
screen_brightness_linux_plugin_handle_system_screen_brightness_changed(ScreenBrightnessLinuxPlugin *self,
                                                                       double brightness) {
    if (self->system_screen_brightness_changed_event_channel == nullptr) {
        return;
    }

    try {
        fl_event_channel_send(self->system_screen_brightness_changed_event_channel,
                              fl_value_new_float(brightness), nullptr, nullptr);
    } catch (const std::exception &exception) {
        std::cout << exception.what() << std::endl;
    }
}

static void
screen_brightness_linux_plugin_handle_application_screen_brightness_changed(ScreenBrightnessLinuxPlugin *self,
                                                                             double brightness) {
    if (self->application_screen_brightness_changed_event_channel == nullptr) {
        return;
    }

    try {
        fl_event_channel_send(self->application_screen_brightness_changed_event_channel,
                              fl_value_new_float(brightness), nullptr, nullptr);
    } catch (const std::exception &exception) {
        std::cout << exception.what() << std::endl;
    }
}

static void screen_brightness_linux_plugin_on_application_pause(ScreenBrightnessLinuxPlugin *self) {
    if (self->system_brightness_ == -1) {
        return;
    }

    try {
        screen_brightness_linux_plugin_set_brightness(self->system_brightness_);
    } catch (const std::exception &exception) {
        std::cout << exception.what() << std::endl;
    }
}

static void screen_brightness_linux_plugin_on_application_resume(ScreenBrightnessLinuxPlugin *self) {
    double minimum_brightness = -1;
    double maximum_brightness = -1;
    double current_brightness = -1;

    screen_brightness_linux_plugin_get_brightness(minimum_brightness, maximum_brightness,
                                                  current_brightness);
    if (minimum_brightness == -1 || maximum_brightness == -1 || current_brightness == -1) {
        return;
    }

    self->minimum_brightness_ = minimum_brightness;
    self->maximum_brightness_ = maximum_brightness;

    double system_brightness = screen_brightness_linux_plugin_get_brightness_percentage(
            minimum_brightness, maximum_brightness, current_brightness);
    self->system_brightness_ = system_brightness;
    screen_brightness_linux_plugin_handle_system_screen_brightness_changed(self, system_brightness);

    if (self->application_brightness_ == -1) {
        screen_brightness_linux_plugin_handle_application_screen_brightness_changed(self,
                                                                                    system_brightness);
        return;
    }

    try {
        screen_brightness_linux_plugin_set_brightness(self->application_brightness_);
    } catch (const std::exception &exception) {
        std::cout << exception.what() << std::endl;
    }
}

static void
screen_brightness_linux_plugin_handle_get_system_screen_brightness_method_call(ScreenBrightnessLinuxPlugin *self,
                                                                                FlMethodCall *method_call) {
    if (self->system_brightness_ == -1) {
        fl_method_call_respond_error(method_call, "-11",
                                     "Could not found system screen brightness value", nullptr,
                                     nullptr);
        return;
    }

    fl_method_call_respond_success(method_call, fl_value_new_float(self->system_brightness_),
                                   nullptr);
}

static void
screen_brightness_linux_plugin_handle_set_system_screen_brightness_method_call(ScreenBrightnessLinuxPlugin *self,
                                                                                FlMethodCall *method_call) {
    g_autoptr(FlValue)
    args = fl_method_call_get_args(method_call);
    if (fl_value_get_type(args) != FL_VALUE_TYPE_MAP) {
        fl_method_call_respond_error(method_call, "-2", "Unexpected error on parameter", nullptr,
                                     nullptr);
        return;
    }

    g_autoptr(FlValue)
    brightness_value = fl_value_lookup_string(args, "brightness");
    if (fl_value_get_type(brightness_value) != FL_VALUE_TYPE_FLOAT) {
        fl_method_call_respond_error(method_call, "-2", "Unexpected error on parameter", nullptr,
                                     nullptr);
        return;
    }

    double brightness = fl_value_get_float(brightness_value);
    try {
        if (self->application_brightness_ == -1) {
            screen_brightness_linux_plugin_set_brightness(brightness);
            screen_brightness_linux_plugin_handle_application_screen_brightness_changed(self,
                                                                                        brightness);
        }
        self->system_brightness_ = brightness;
        screen_brightness_linux_plugin_handle_system_screen_brightness_changed(self, brightness);
        fl_method_call_respond_success(method_call, nullptr, nullptr);
    } catch (const std::exception &exception) {
        fl_method_call_respond_error(method_call, "-1",
                                     "Unable to change system screen brightness", nullptr, nullptr);
    }
}

static void
screen_brightness_linux_plugin_handle_get_application_screen_brightness_method_call(ScreenBrightnessLinuxPlugin *self,
                                                                                     FlMethodCall *method_call) {
    double minimum_brightness = -1;
    double maximum_brightness = -1;
    double current_brightness = -1;

    screen_brightness_linux_plugin_get_brightness(minimum_brightness, maximum_brightness,
                                                  current_brightness);
    if (minimum_brightness == -1 || maximum_brightness == -1 || current_brightness == -1) {
        fl_method_call_respond_error(method_call, "-11",
                                     "Could not found application screen brightness value", nullptr,
                                     nullptr);
        return;
    }

    self->minimum_brightness_ = minimum_brightness;
    self->maximum_brightness_ = maximum_brightness;

    double brightness_percentage = screen_brightness_linux_plugin_get_brightness_percentage(
            minimum_brightness, maximum_brightness, current_brightness);

    fl_method_call_respond_success(method_call, fl_value_new_float(brightness_percentage), nullptr);
}

static void
screen_brightness_linux_plugin_handle_set_application_screen_brightness_method_call(ScreenBrightnessLinuxPlugin *self,
                                                                                     FlMethodCall *method_call) {
    g_autoptr(FlValue)
    args = fl_method_call_get_args(method_call);
    if (fl_value_get_type(args) != FL_VALUE_TYPE_MAP) {
        fl_method_call_respond_error(method_call, "-2", "Unexpected error on parameter", nullptr,
                                     nullptr);
        return;
    }

    g_autoptr(FlValue)
    brightness_value = fl_value_lookup_string(args, "brightness");
    if (fl_value_get_type(brightness_value) != FL_VALUE_TYPE_FLOAT) {
        fl_method_call_respond_error(method_call, "-2", "Unexpected error on parameter", nullptr,
                                     nullptr);
        return;
    }

    double brightness = fl_value_get_float(brightness_value);
    try {
        screen_brightness_linux_plugin_set_brightness(brightness);
        self->application_brightness_ = brightness;
        screen_brightness_linux_plugin_handle_application_screen_brightness_changed(self, brightness);
        fl_method_call_respond_success(method_call, nullptr, nullptr);
    } catch (const std::exception &exception) {
        fl_method_call_respond_error(method_call, "-1",
                                     "Unable to change application screen brightness", nullptr,
                                     nullptr);
    }
}

static void
screen_brightness_linux_plugin_handle_reset_application_screen_brightness_method_call(ScreenBrightnessLinuxPlugin *self,
                                                                                       FlMethodCall *method_call) {
    if (self->system_brightness_ == -1) {
        fl_method_call_respond_error(method_call, "-2", "Unexpected error on null brightness",
                                     nullptr, nullptr);
        return;
    }

    try {
        screen_brightness_linux_plugin_set_brightness(self->system_brightness_);
        self->application_brightness_ = -1;
        screen_brightness_linux_plugin_handle_application_screen_brightness_changed(self,
                                                                                    self->system_brightness_);
        fl_method_call_respond_success(method_call, nullptr, nullptr);
    } catch (const std::exception &exception) {
        fl_method_call_respond_error(method_call, "-1",
                                     "Unable to reset application screen brightness", nullptr,
                                     nullptr);
    }
}

static void
screen_brightness_linux_plugin_handle_has_application_screen_brightness_changed_method_call(ScreenBrightnessLinuxPlugin *self,
                                                                                             FlMethodCall *method_call) {
    fl_method_call_respond_success(method_call,
                                   fl_value_new_bool(self->application_brightness_ != -1), nullptr);
}

static void screen_brightness_linux_plugin_handle_is_auto_reset_method_call(ScreenBrightnessLinuxPlugin *self,
                                                                             FlMethodCall *method_call) {
    fl_method_call_respond_success(method_call, fl_value_new_bool(self->is_auto_reset_), nullptr);
}

static void screen_brightness_linux_plugin_handle_set_auto_reset_method_call(ScreenBrightnessLinuxPlugin *self,
                                                                              FlMethodCall *method_call) {
    g_autoptr(FlValue)
    args = fl_method_call_get_args(method_call);
    if (fl_value_get_type(args) != FL_VALUE_TYPE_MAP) {
        fl_method_call_respond_error(method_call, "-2", "Unexpected error on parameter", nullptr,
                                     nullptr);
        return;
    }

    g_autoptr(FlValue)
    isAutoResetValue = fl_value_lookup_string(args, "isAutoReset");
    if (fl_value_get_type(isAutoResetValue) != FL_VALUE_TYPE_BOOL) {
        fl_method_call_respond_error(method_call, "-2", "Unexpected error on parameter", nullptr,
                                     nullptr);
        return;
    }

    self->is_auto_reset_ = fl_value_get_bool(isAutoResetValue);
    fl_method_call_respond_success(method_call, nullptr, nullptr);
}

static void screen_brightness_linux_plugin_handle_is_animate_method_call(ScreenBrightnessLinuxPlugin *self,
                                                                          FlMethodCall *method_call) {
    fl_method_call_respond_success(method_call, fl_value_new_bool(self->is_animate_), nullptr);
}

static void screen_brightness_linux_plugin_handle_set_animate_method_call(ScreenBrightnessLinuxPlugin *self,
                                                                           FlMethodCall *method_call) {
    g_autoptr(FlValue)
    args = fl_method_call_get_args(method_call);
    if (fl_value_get_type(args) != FL_VALUE_TYPE_MAP) {
        fl_method_call_respond_error(method_call, "-2", "Unexpected error on parameter", nullptr,
                                     nullptr);
        return;
    }

    g_autoptr(FlValue)
    isAnimateValue = fl_value_lookup_string(args, "isAnimate");
    if (fl_value_get_type(isAnimateValue) != FL_VALUE_TYPE_BOOL) {
        fl_method_call_respond_error(method_call, "-2", "Unexpected error on parameter", nullptr,
                                     nullptr);
        return;
    }

    self->is_animate_ = fl_value_get_bool(isAnimateValue);
    fl_method_call_respond_success(method_call, nullptr, nullptr);
}

static void screen_brightness_linux_plugin_handle_can_change_system_brightness_method_call(ScreenBrightnessLinuxPlugin *self,
                                                                                            FlMethodCall *method_call) {
    fl_method_call_respond_success(method_call, fl_value_new_bool(true), nullptr);
}

static void on_toplevel_notify_is_active(GObject *object, GParamSpec *pspec, gpointer user_data) {
    ScreenBrightnessLinuxPlugin *self = SCREEN_BRIGHTNESS_LINUX_PLUGIN(user_data);
    if (!self->is_auto_reset_) {
        return;
    }

    gboolean is_active;
    g_object_get(object, "is-active", &is_active, NULL);
    if (is_active) {
        screen_brightness_linux_plugin_on_application_resume(self);
    } else {
        screen_brightness_linux_plugin_on_application_pause(self);
    }
}

static gboolean on_toplevel_window_state_event(GtkWidget *widget, GdkEventWindowState *event,
                                               gpointer user_data) {
    ScreenBrightnessLinuxPlugin *self = SCREEN_BRIGHTNESS_LINUX_PLUGIN(user_data);
    if (!self->is_auto_reset_) {
        return FALSE;
    }

    if (event->changed_mask & GDK_WINDOW_STATE_ICONIFIED) {
        if (event->new_window_state & GDK_WINDOW_STATE_ICONIFIED) {
            screen_brightness_linux_plugin_on_application_pause(self);
        } else {
            screen_brightness_linux_plugin_on_application_resume(self);
        }
    }
    return FALSE;
}

static void screen_brightness_linux_plugin_dispose(GObject *object) {
    ScreenBrightnessLinuxPlugin *self = SCREEN_BRIGHTNESS_LINUX_PLUGIN(object);

    if (self->toplevel_window != nullptr && GTK_IS_WINDOW(self->toplevel_window)) {
        if (self->is_active_handler_id > 0) {
            g_signal_handler_disconnect(self->toplevel_window, self->is_active_handler_id);
            self->is_active_handler_id = 0;
        }
        if (self->window_state_handler_id > 0) {
            g_signal_handler_disconnect(self->toplevel_window, self->window_state_handler_id);
            self->window_state_handler_id = 0;
        }
    }
    self->toplevel_window = nullptr;

    g_clear_object(&self->registrar);
    g_clear_object(&self->method_channel);
    g_clear_object(&self->system_screen_brightness_changed_event_channel);
    g_clear_object(&self->application_screen_brightness_changed_event_channel);

    G_OBJECT_CLASS(screen_brightness_linux_plugin_parent_class)->dispose(object);
}

static void screen_brightness_linux_plugin_class_init(ScreenBrightnessLinuxPluginClass *klass) {
    G_OBJECT_CLASS(klass)->dispose = screen_brightness_linux_plugin_dispose;
}

static void screen_brightness_linux_plugin_init(ScreenBrightnessLinuxPlugin *self) {

}

static void method_call_cb(FlMethodChannel *channel, FlMethodCall *method_call,
                           gpointer user_data) {
    ScreenBrightnessLinuxPlugin *plugin = SCREEN_BRIGHTNESS_LINUX_PLUGIN(user_data);
    screen_brightness_linux_plugin_handle_method_call(plugin, method_call);
}

void screen_brightness_linux_plugin_register_with_registrar(FlPluginRegistrar *registrar) {
    ScreenBrightnessLinuxPlugin *self = SCREEN_BRIGHTNESS_LINUX_PLUGIN(
            g_object_new(screen_brightness_linux_plugin_get_type(), nullptr));

    self->registrar = FL_PLUGIN_REGISTRAR(g_object_ref(registrar));

    // Initialize system brightness
    double minimum_brightness = -1;
    double maximum_brightness = -1;
    double current_brightness = -1;
    screen_brightness_linux_plugin_get_brightness(minimum_brightness, maximum_brightness,
                                                  current_brightness);
    if (minimum_brightness != -1 && maximum_brightness != -1 && current_brightness != -1) {
        self->minimum_brightness_ = minimum_brightness;
        self->maximum_brightness_ = maximum_brightness;
        self->system_brightness_ = screen_brightness_linux_plugin_get_brightness_percentage(
                minimum_brightness, maximum_brightness, current_brightness);
    }

    g_autoptr(FlStandardMethodCodec)
    codec = fl_standard_method_codec_new();
    self->method_channel =
            fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                                  "github.com/aaassseee/screen_brightness",
                                  FL_METHOD_CODEC(codec));
    fl_method_channel_set_method_call_handler(self->method_channel, method_call_cb,
                                              g_object_ref(self),
                                              g_object_unref);

    self->system_screen_brightness_changed_event_channel = fl_event_channel_new(
            fl_plugin_registrar_get_messenger(registrar),
            "github.com/aaassseee/screen_brightness/system_brightness_changed",
            FL_METHOD_CODEC(codec));
    fl_event_channel_set_stream_handlers(self->system_screen_brightness_changed_event_channel,
                                         [](FlEventChannel *, FlValue *,
                                            gpointer user_data) -> FlMethodErrorResponse * {
                                             return nullptr;
                                         },
                                         [](FlEventChannel *, FlValue *,
                                            gpointer user_data) -> FlMethodErrorResponse * {
                                             return nullptr;
                                         },
                                         g_object_ref(self), g_object_unref);

    self->application_screen_brightness_changed_event_channel = fl_event_channel_new(
            fl_plugin_registrar_get_messenger(registrar),
            "github.com/aaassseee/screen_brightness/application_brightness_changed",
            FL_METHOD_CODEC(codec));
    fl_event_channel_set_stream_handlers(self->application_screen_brightness_changed_event_channel,
                                         [](FlEventChannel *, FlValue *,
                                            gpointer user_data) -> FlMethodErrorResponse * {
                                             return nullptr;
                                         },
                                         [](FlEventChannel *, FlValue *,
                                            gpointer user_data) -> FlMethodErrorResponse * {
                                             return nullptr;
                                         },
                                         g_object_ref(self), g_object_unref);

    // Connect to window lifecycle signals for auto-reset
    GtkWidget *view = GTK_WIDGET(fl_plugin_registrar_get_view(registrar));
    if (view != nullptr) {
        GtkWidget *toplevel = gtk_widget_get_toplevel(view);
        if (GTK_IS_WINDOW(toplevel)) {
            self->toplevel_window = toplevel;
            self->is_active_handler_id = g_signal_connect(toplevel, "notify::is-active",
                                                          G_CALLBACK(
                                                                  on_toplevel_notify_is_active),
                                                          self);
            self->window_state_handler_id = g_signal_connect(toplevel, "window-state-event",
                                                             G_CALLBACK(
                                                                     on_toplevel_window_state_event),
                                                             self);
        }
    }

    g_object_unref(self);
}
