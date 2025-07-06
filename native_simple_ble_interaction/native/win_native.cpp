#include "dart_api_dl.h"
#include "dart_api_dl.c"

#include <iostream>
#include <chrono>
#include <thread>
#include <vector>
#include <cstring>

#include <simpleble/SimpleBLE.h>

static SimpleBLE::Adapter *adapter;
static Dart_Port scan_update_port = 0;

static std::vector<Dart_Port> notification_ports;

static std::vector<SimpleBLE::Peripheral> devices;
static std::vector<std::string> device_addresses;

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

    /**
     * @brief initialize the dart-api connection.
     *
     * usage:
     * ```dart
     *      final initApi = NativeApi.initializeApiDlData;
     *      dartInitializeApiDl(initApi);
     * ```
     *
     * @param data
     */
    void dart_initialize_api_dl(void *data)
    {
        Dart_InitializeApiDL(data);
    }

    /**
     * @brief register a scan-update port, which recieves
     *  scan-updates
     *
     * usage:
     * ```dart
     *  final scanUpdateReceivePort = ReceivePort();
     *  registerScanUpdatePort(scanUpdateReceivePort.sendPort.nativePort);
     *  scanUpdateReceivePort.listen(...)
     * ```
     * @param port native port
     */
    void register_scan_update_port(Dart_Port port)
    {
        scan_update_port = port;
    }

    /**
     * @brief natively delete a byte-array
     *
     * @param data the byte pointer
     */
    void delete_uint8_array(uint8_t *data)
    {
        delete[] data;
    }

    /**
     * @brief check wether the bluetooth is enabled system-wide
     *
     * @return true if enabled,
     * @return false if disabled
     */
    bool bluetooth_is_enabled()
    {
        return SimpleBLE::Adapter::bluetooth_enabled();
    }

    /**
     * @brief initialize the bluetooth adapter before starting a scan
     *
     * @return true if an adapter was found successfully,
     * @return false if no valid adapter was found
     */
    bool initialize_adapter()
    {
        auto adapters = SimpleBLE::Adapter::get_adapters();
        if (adapters.empty())
            return false;

        adapter = new SimpleBLE::Adapter(adapters[0]);
        return true;
    }

    /**
     * @brief let a bluetooth adapter scan for a certain amount of time.
     *  has to be used **after** `initialize_adapter()`
     *
     * @param milliseconds scan duration
     */
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

    // TODO: rename this function to cleanup scan

    /**
     * @brief cleanup after scan to ensure no background tasks
     *  are preformed anymore
     *
     */
    void cleanup()
    {
        if (adapter != nullptr)
        {
            adapter->scan_stop();
            delete adapter;
            adapter = nullptr;
        }
    }

    /**
     * @brief connect to a discovered device via its id
     *
     * @param id device's id
     */
    void connect_to_device(int id)
    {
        SimpleBLE::Peripheral device = devices.at(id);
        device.connect();

        // #ifdef DEBUG
        //         printf("c++: connected to device\n");
        // #endif
    }

    /**
     * @brief disconnect from a connected device via its id
     *
     * @param id device's id
     */
    void disconnect_from_device(int id)
    {
        auto device = devices.at(id);
        device.disconnect();
    }

    /**
     * @brief Get the address of a device with its id
     *
     * @param id device's id
     * @return const char* c-string of device-address
     */
    const char *get_device_address(int id)
    {
        const std::string &addr = device_addresses.at(id).c_str();
        return strdup(addr.c_str());
    }

    // TODO: make idempotent
    // MAYBE TODO: combine with discover_device_characteristics

    /**
     * @brief initialize the services for a given device
     *
     * @param device_id device's id
     */
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

    /**
     * @brief Get the number of services discovered for a device.
     *
     * @param device_id device's id
     * @return int
     */
    int get_number_of_services(int device_id)
    {
        return device_services_map[device_id].size();
    }

    /**
     * @brief Get the uuid of a service with servic_id for a device
     *  with device_id.
     *
     * @param device_id
     * @param service_id
     * @return const char* uuid as c-string
     */
    const char *get_service_uuid(int device_id, int service_id)
    {
        // const std::string &addr = device_services_uuid_map[device_id][service_id];
        // return strdup(addr.c_str());
        return device_services_uuid_map[device_id][service_id].c_str();
    }

    /**
     * @brief Initialize the Characterstistics for a given service with
     *  service_id on the device with device_id.
     *
     * @param device_id
     * @param service_id
     */
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

    /**
     * @brief Get the number of characteristics discovered for the service
     *  with service_id on the device with device_id.
     *
     * @param device_id
     * @param service_id
     * @return int number of characteristics
     */
    int get_number_of_characteristics(int device_id, int service_id)
    {
        return device_characteristic_map[device_id][service_id].size();
    }

    /**
     * @brief Get the uuid-string for a characteristic with characteristic_id
     *  under the service with service_id on the device with device_id.
     *
     * @param device_id
     * @param service_id
     * @param characteristic_id
     * @return const char* uuid as c-string
     */
    const char *get_characteristic_uuid(int device_id, int service_id, int characteristic_id)
    {
        // const std::string &addr = device_characteristic_uuid_map[device_id][service_id][characteristic_id];
        // return strdup(addr.c_str());
        return device_characteristic_uuid_map[device_id][service_id][characteristic_id].c_str();
    }

    /* MAYBE TODO: rename to read_from_characteristic */

    /**
     * @brief read from a characteristic
     * @warning make a call to `delete_uint8_array()` after processing the data to prevent a memory-leak !
     *
     * @param device_id
     * @param service_id
     * @param characteristic_id
     * @return uint8_t*
     */
    uint8_t *read_characteristic(int device_id, int service_id, int characteristic_id)
    {
        SimpleBLE::Peripheral device(devices.at(device_id));
        SimpleBLE::BluetoothUUID service_uuid(device_services_uuid_map[device_id][service_id]);
        SimpleBLE::BluetoothUUID char_uuid(device_characteristic_uuid_map[device_id][service_id][characteristic_id]);

        auto data = device.read(service_uuid, char_uuid);
        size_t size = data.size();
        if (size > 255)
        {
            printf("c++: invalid read data size");
            return nullptr;
        }
        uint8_t size_as_byte = static_cast<uint8_t>(size);
        uint8_t *dataArray = new uint8_t[size + 1];

        /* TODO: as data can be > 256 bytes long: use first two bytes for data length */
        // embed data length in the first byte
        dataArray[0] = size_as_byte;

        std::memcpy(dataArray + 1, data.data(), size_as_byte);
        return dataArray;
    }

    /**
     * @brief Write byte-data to a characteristic.
     *
     * @param device_id
     * @param service_id
     * @param characteristic_id
     * @param data
     * @param data_size
     */
    void write_to_characteristic(int device_id, int service_id, int characteristic_id, uint8_t *data, int data_size)
    {
        SimpleBLE::Peripheral device(devices.at(device_id));
        SimpleBLE::BluetoothUUID service_uuid(device_services_uuid_map[device_id][service_id]);
        SimpleBLE::BluetoothUUID char_uuid(device_characteristic_uuid_map[device_id][service_id][characteristic_id]);

        SimpleBLE::ByteArray data_as_byte_array(data, data_size);

        device.write_request(service_uuid, char_uuid, data_as_byte_array);
    }

    /**
     * @brief Register a notification port to receive asynchronous
     *  characteristic-notifications.
     *
     * @param port
     * @return int
     */
    int register_notification_port(Dart_Port port)
    {
        notification_ports.push_back(port);
        return notification_ports.size() - 1;
    }

    /**
     * @brief Subscribe to a characteristic and receive async-notifications
     *  on the registered port_id.
     *
     * @param device_id
     * @param service_id
     * @param characteristic_id
     * @param port_id
     */
    void subscribe_to_characteristic(int device_id, int service_id, int characteristic_id, int port_id)
    {
        printf("c++: subscribing\n");
        SimpleBLE::Peripheral device(devices.at(device_id));
        SimpleBLE::BluetoothUUID service_uuid(device_services_uuid_map[device_id][service_id]);
        SimpleBLE::BluetoothUUID char_uuid(device_characteristic_uuid_map[device_id][service_id][characteristic_id]);

        device.indicate(
            service_uuid,
            char_uuid,
            [port_id](SimpleBLE::ByteArray payload)
            {
                Dart_CObject msg;

                msg.type = Dart_CObject_kTypedData;
                msg.value.as_typed_data.type = Dart_TypedData_kUint8;
                msg.value.as_typed_data.length = payload.size();
                msg.value.as_typed_data.values = payload.data();

                Dart_PostCObject_DL(notification_ports[port_id], &msg);
            });
    }

    /**
     * @brief Unsubscribe from a previously subscribed characteristic.
     *
     * @param device_id
     * @param service_id
     * @param characteristic_id
     */
    void unsubscribe_from_characteristic(int device_id, int service_id, int characteristic_id)
    {
        SimpleBLE::Peripheral device(devices.at(device_id));
        SimpleBLE::BluetoothUUID service_uuid(device_services_uuid_map[device_id][service_id]);
        SimpleBLE::BluetoothUUID char_uuid(device_characteristic_uuid_map[device_id][service_id][characteristic_id]);

        device.unsubscribe(service_uuid, char_uuid);
    }

    /**
     * @brief Dispose a device by its id to close all related background tasks
     *
     * @param id devices'id
     */
    void dispose_device(int id)
    {
        SimpleBLE::Peripheral device(devices.at(id));

        delete &device;
    }
}