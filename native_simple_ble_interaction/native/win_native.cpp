#include "dart_api_dl.h"
#include "dart_api_dl.c"

#include <iostream>
#include <chrono>
#include <thread>
#include <vector>
#include <cstring>

#include <simpleble/SimpleBLE.h>

// static std::vector<Dart_Port> ports;

static SimpleBLE::Adapter *adapter;
static Dart_Port scan_update_port = 0;

static std::vector<SimpleBLE::Peripheral> devices;
static std::vector<std::string> device_addresses;

// version a
static std::map<int, std::vector<SimpleBLE::Service>> device_services_map;
static std::map<int, std::vector<std::string>> device_services_uuid_map;

static std::map<int, std::vector<std::vector<SimpleBLE::Characteristic>>> device_characteristic_map;
static std::map<int, std::vector<std::vector<std::string>>> device_characteristic_uuid_map;

// alternative: (check with uuid conversion)
// static std::map<int, std::map<std::string, SimpleBLE::Service>>
// static std::map<int, std::map<std::string, std::map<std::string, SimpleBLE::Characteristic>>>

// #define DEBUG

extern "C"
{
    void dart_initialize_api_dl(void *data)
    {
        Dart_InitializeApiDL(data);
    }

    void register_scan_update_port(Dart_Port port)
    {
        scan_update_port = port;
    }

    // int registerSendPort(Dart_Port port)
    // {
    //     ports.push_back(port);
    //     return ports.size() - 1;
    // }

    bool bluetooth_is_enabled()
    {
        return SimpleBLE::Adapter::bluetooth_enabled();
    }

    bool initialize_adapter()
    {
        auto adapters = SimpleBLE::Adapter::get_adapters();
        if (adapters.empty())
            return false;

        adapter = new SimpleBLE::Adapter(adapters[0]);
        return true;
    }

    void scan_for(int milliseconds)
    {

        adapter->set_callback_on_scan_found(
            [](SimpleBLE::Peripheral p) -> void
            {
                // TODO maybe make access to devices atomic
                devices.push_back(p);
                device_addresses.push_back(p.address());
                Dart_CObject msg;
                msg.type = Dart_CObject_kInt32;
                msg.value.as_int32 = devices.size() - 1;
                // TODO maybe send id AND remote addr as struct
                Dart_PostCObject_DL(scan_update_port, &msg);
            });

        adapter->scan_for(milliseconds);
    }

    void cleanup()
    {
        if (adapter != nullptr)
        {
            adapter->scan_stop();
            delete adapter;
            adapter = nullptr;
        }
    }

    void connect_to_device(int id)
    {
        SimpleBLE::Peripheral device = devices.at(id);
        device.connect();

        // #ifdef DEBUG
        //         printf("c++: connected to device\n");
        // #endif
    }

    void disconnect_from_device(int id)
    {
        auto device = devices.at(id);
        device.disconnect();
    }

    const char *get_device_address(int id)
    {
        const std::string &addr = device_addresses.at(id).c_str();
        return strdup(addr.c_str());
    }

    // TODO make idempotent
    void discover_device_services(int device_id)
    {
        auto device = devices.at(device_id);
        std::vector svcs = device.services();
        device_services_map[device_id] = svcs;

        // gather service uuids
        std::vector<SimpleBLE::BluetoothUUID> uuids;
        for (auto svc : svcs)
        {
            uuids.push_back(svc.uuid());
            // preset an empty vector for each service
            device_characteristic_map[device_id].push_back(std::vector<SimpleBLE::Characteristic>());
            device_characteristic_uuid_map[device_id].push_back(std::vector<std::string>());
        }
        device_services_uuid_map[device_id] = uuids;
    }

    int get_number_of_services(int device_id)
    {
        return device_services_map[device_id].size();
    }

    const char *get_service_uuid(int device_id, int service_id)
    {
        // const std::string &addr = device_services_uuid_map[device_id][service_id];
        // return strdup(addr.c_str());
        return device_services_uuid_map[device_id][service_id].c_str();
    }

    void discover_service_characteristics(int device_id, int service_id)
    {
        auto service = device_services_map.at(device_id).at(service_id);
        std::vector chars = service.characteristics();

        // redefine preset-vector

        if (device_characteristic_map[device_id].size() > service_id)
        {
            device_characteristic_map[device_id][service_id] = chars;
        }
        else
        {
            printf("c++: fatal error: device_id not preset for chars\n");
            return;
        }

        // gather characteristic uuids
        std::vector<SimpleBLE::BluetoothUUID> uuids;
        for (auto characteristic : chars)
        {
            uuids.push_back(characteristic.uuid());
        }

        if (device_characteristic_uuid_map[device_id].size() > service_id)
        {
            device_characteristic_uuid_map[device_id][service_id] = uuids;
        }
        else
        {
            printf("c++: fatal error: device_id not preset for uuids\n");
            return;
        }
    }

    int get_number_of_characteristics(int device_id, int service_id)
    {
        return device_characteristic_map[device_id][service_id].size();
    }

    const char *get_characteristic_uuid(int device_id, int service_id, int characteristic_id)
    {
        // const std::string &addr = device_characteristic_uuid_map[device_id][service_id][characteristic_id];
        // return strdup(addr.c_str());
        return device_characteristic_uuid_map[device_id][service_id][characteristic_id].c_str();
    }
}