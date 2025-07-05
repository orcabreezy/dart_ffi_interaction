#include <vector>
#include <simpleble/simpleBLE.h>

class BleDevice
{
public:
    BleDevice(SimpleBLE::Peripheral device) : internal(device) {}

    void connect()
    {
        internal.connect();
    };

    void disconnect()
    {
        internal.disconnect();
    }

    std::vector<BleService> getServices()
    {
        std::vector<BleService> output;

        for (auto service : internal.services())
        {
            output.push_back(BleService(service, this));
        }
    }

    char *readFromCharacteristic(SimpleBLE::BluetoothUUID service, SimpleBLE::BluetoothUUID characteristic)
    {
        return &((std::string)internal.read(service, characteristic))[0];
    }

private:
    SimpleBLE::Peripheral internal;
    SimpleBLE::BluetoothAddress address;
    std::string identifier;
};

class BleService
{
public:
    BleService(SimpleBLE::Service service, BleDevice *device)
        : service(service), device(device), uuid(service.uuid()) {}
    std::vector<BleCharacteristic> getCharacteristics()
    {
        std::vector<BleCharacteristic> output;

        for (auto characteristic : service.characteristics())
        {
            output.push_back(BleCharacteristic(characteristic, this));
        }
    }

    BleDevice *getBleDevice()
    {
        return device;
    }

    SimpleBLE::BluetoothUUID getUuid()
    {
        return uuid;
    }

private:
    SimpleBLE::Service service;
    BleDevice *device;
    const SimpleBLE::BluetoothUUID uuid;
};

class BleCharacteristic
{
public:
    BleCharacteristic(SimpleBLE::Characteristic characteristic, BleService *service)
        : characteristic(characteristic), service(service), uuid(characteristic.uuid()) {}

    char *read()
    {
        if (!characteristic.can_read())
            return nullptr;

        service->getBleDevice()->readFromCharacteristic(uuid, service->getUuid());
    }
    void write(char *data);
    void subscribe();
    void unsubscribe();

private:
    SimpleBLE::Characteristic characteristic;
    BleService *service;
    const SimpleBLE::BluetoothUUID uuid;
};
