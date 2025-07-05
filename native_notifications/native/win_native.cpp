#include "dart_api_dl.h"
#include "dart_api_dl.c"

#include <iostream>
#include <chrono>
#include <thread>

// sequential stream messages
static Dart_Port dart_port = 0;
static std::atomic<bool> running(false);

extern "C"
{
    void dartInitializeApiDl(void *data)
    {
        Dart_InitializeApiDL(data);
    }

    void registerSendPort(Dart_Port port)
    {
        dart_port = port;
    }

    void sendMessage()
    {
        int counter = 0;
        while (counter < 10)
        {
            Dart_CObject msg;
            msg.type = Dart_CObject_kInt32;
            msg.value.as_int32 = counter++;
            Dart_PostCObject_DL(dart_port, &msg);
            std::this_thread::sleep_for(std::chrono::seconds(1));
        }
    }

    // void startMessageLoop()
    // {
    //     if (running.load())
    //         return;
    //     running = true;

    //     std::thread([]
    //                 {
    //         int counter = 0;
    //         while (running.load()) {
    //             Dart_CObject msg;
    //             msg.type = Dart_CObject_kInt32;
    //             msg.value.as_int32 = counter++;

    //             Dart_PostCObject_DL(dart_port, &msg);
    //             std::this_thread::sleep_for(std::chrono::seconds(2));
    //         } })
    //         .detach();
    // }

    // void stopMessageLoop()
    // {
    //     running = false;
    // }
}
