#include "dart_api_dl.h"
#include "dart_api_dl.c"

#include <iostream>
#include <chrono>
#include <thread>
#include <vector>

// static Dart_Port dart_port = 0;

struct SomeObject
{
    SomeObject(std::string name, int age, std::vector<int> data)
        : name(name), age(age), data(data) {}

    std::string name;
    int age;
    std::vector<int> data;
};

static SomeObject *globalObject;

extern "C"
{
    void initGlobalObject(char *name, int age, int *data, int dataSize)
    {
        std::vector<int> dataVector;
        for (int i = 0; i < dataSize; i++)
        {
            dataVector.push_back(data[i]);
        }

        globalObject = new SomeObject(name, age, dataVector);

        printf("c++: successfully initialized object");
    }

    const char *getGlobalObjectName()
    {
        return globalObject->name.c_str();
    }

    const int getGlobalObjectAge()
    {
        return globalObject->age;
    }

    const int getGlobalObjectDataAt(const int i)
    {
        return globalObject->data.at(i);
    }
}
