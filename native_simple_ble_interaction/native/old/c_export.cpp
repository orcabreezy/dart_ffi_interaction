
#include "dart_api_dl.h"
#include "dart_api_dl.c"

#include <iostream>
#include <simpleble/SimpleBLE.h>
#include <cstring> // For memcpy
#include <atomic>
#include <chrono>
#include <thread>

extern "C"
{
    // Structure to hold device information
    struct DeviceInfo
    {
        char identifier[256];
        char address[256];
    };

    // Structure to hold characteristic information
    struct CharacteristicInfo
    {
        char service_uuid[256];
        char characteristic_uuid[256];
    };

    // Check if Bluetooth is enabled
    bool bluetooth_enabled()
    {
        return SimpleBLE::Adapter::bluetooth_enabled();
    }

    int get_peripheral_size()
    {
        return sizeof(SimpleBLE::Peripheral);
    }

    // Get the first available adapter
    bool get_adapter(DeviceInfo *adapter_info)
    {
        auto adapters = SimpleBLE::Adapter::get_adapters();
        if (adapters.empty())
        {
            return false;
        }

        auto adapter = adapters[0];
        strncpy_s(adapter_info->identifier, adapter.identifier().c_str(), sizeof(adapter_info->identifier));
        strncpy_s(adapter_info->address, adapter.address().c_str(), sizeof(adapter_info->address));
        return true;
    }

    // Scan for devices
    void *scan_for_devices(DeviceInfo *devices, int max_devices, int scan_duration_ms)
    {
        auto adapters = SimpleBLE::Adapter::get_adapters();
        if (adapters.empty())
        {
            return 0;
        }

        auto adapter = adapters[0];
        adapter.scan_for(scan_duration_ms);

        std::vector<SimpleBLE::Peripheral> peripherals = adapter.scan_get_results();
        int count = 0;

        for (auto peripheral : peripherals)
        {
            if (count >= max_devices)
            {
                break;
            }
            strncpy_s(devices[count].identifier, peripheral.identifier().c_str(), sizeof(devices[count].identifier));
            strncpy_s(devices[count].address, peripheral.address().c_str(), sizeof(devices[count].address));

            count++;
        }

        return new SimpleBLE::Peripheral(peripherals[0]);
    }

    bool connect_to_predetermined(SimpleBLE::Peripheral *device_ptr)
    {
        if (device_ptr == nullptr)
        {
            return false;
        }
        auto *device = static_cast<SimpleBLE::Peripheral *>(device_ptr);

        device->connect();
        return true;
    }

    // Connect to a device by address
    void *connect_to_device(const char *address)
    {
        auto adapters = SimpleBLE::Adapter::get_adapters();
        if (adapters.empty())
        {
            return nullptr;
        }

        auto adapter = adapters[0];
        adapter.scan_for(2000);
        auto peripherals = adapter.scan_get_results();

        for (auto &peripheral : peripherals)
        {
            if (peripheral.address() == SimpleBLE::BluetoothAddress(address))
            {
                peripheral.connect();
                if (peripheral.is_connected())
                {
                    return new SimpleBLE::Peripheral(peripheral);
                }
            }
        }

        return nullptr;
    }

    // Disconnect from a device
    void disconnect_device(void *device_ptr)
    {
        if (device_ptr == nullptr)
        {
            return;
        }

        auto *device = static_cast<SimpleBLE::Peripheral *>(device_ptr);
        device->disconnect();
        delete device;
        printf("c++: disconnected from device\n");
    }

    // List characteristics of a connected device
    int list_characteristics(void *device_ptr, CharacteristicInfo *characteristics, int max_characteristics)
    {
        if (device_ptr == nullptr)
        {
            return 0;
        }

        auto *device = static_cast<SimpleBLE::Peripheral *>(device_ptr);
        auto services = device->services();

        int count = 0;
        for (auto &service : services)
        {
            for (auto &characteristic : service.characteristics())
            {
                if (count >= max_characteristics)
                {
                    break;
                }
                strncpy_s(characteristics[count].service_uuid, service.uuid().c_str(), sizeof(characteristics[count].service_uuid));
                strncpy_s(characteristics[count].characteristic_uuid, characteristic.uuid().c_str(), sizeof(characteristics[count].characteristic_uuid));
                count++;
            }
        }

        return count;
    }

    // Read a characteristic
    int read_characteristic(void *device_ptr, const char *service_uuid, const char *characteristic_uuid, char *buffer, int buffer_size)
    {
        if (device_ptr == nullptr)
        {
            return 0;
        }

        auto *device = static_cast<SimpleBLE::Peripheral *>(device_ptr);
        auto data = device->read(SimpleBLE::BluetoothUUID(service_uuid), SimpleBLE::BluetoothUUID(characteristic_uuid));

        int size = std::min(static_cast<int>(data.size()), buffer_size);
        memcpy(buffer, data.data(), size);
        return size;
    }
}