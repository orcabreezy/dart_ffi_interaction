#include <iostream>
#include <simpleble/SimpleBLE.h>

int main(int argc, char **argv)
{

    // check if bluetooth is enabled on this device
    if (!SimpleBLE::Adapter::bluetooth_enabled())
    {
        std::cout << "Bluetooth is not enabled" << std::endl;
        return 1;
    }

    std::cout << "Bluetooth is enabled!" << std::endl;

    // check if there are bluetooth adapters available
    auto adapters = SimpleBLE::Adapter::get_adapters();
    if (adapters.empty())
    {
        std::cout << "No Bluetooth adapters found" << std::endl;
        return 1;
    }

    auto adapter = adapters[0];
    std::cout << "adapter identifier: " << adapter.identifier() << std::endl;
    std::cout << "Adapter address: " << adapter.address() << std::endl;

    // scan for devices
    adapter.scan_for(5000);

    std::vector<SimpleBLE::Peripheral> peripherals = adapter.scan_get_results();

    for (auto peripheral : peripherals)
    {
        std::cout << "Peripheral identifier: " << peripheral.identifier() << std::endl;
        std::cout << "Peripheral address: " << peripheral.address() << std::endl;
    }

    // connect to the movesense device if found
    SimpleBLE::Peripheral movSenseDevice;

    for (auto peripheral : peripherals)
    {
        if (peripheral.address() == SimpleBLE::BluetoothAddress("74:92:ba:10:fd:2b"))
            movSenseDevice = peripheral;
    }

    if (&movSenseDevice == nullptr)
    {
        std::cout << "movesense device was not found" << std::endl;
        return 1;
    }

    movSenseDevice.connect();

    if (!movSenseDevice.is_connected())
    {
        std::cout << "there was an error when connecting" << std::endl;
        return 1;
    }

    std::cout << "movesense sensor was connected to" << std::endl;

    // list out all service:characteristic pairs
    std::vector<std::pair<SimpleBLE::BluetoothUUID, SimpleBLE::BluetoothUUID>> uuids;
    for (auto service : movSenseDevice.services())
    {
        for (auto characteristic : service.characteristics())
        {
            uuids.push_back(std::make_pair(service.uuid(), characteristic.uuid()));
        }
    }

    std::cout << "listing out characteristics" << std::endl;

    for (auto uuid : uuids)
    {
        std::cout << "service: " << uuid.first << " " << "characteristic: " << uuid.second << std::endl;
    }

    // read out manufacturer characteristic
    auto deviceInformationService = SimpleBLE::BluetoothUUID("0000180a-0000-1000-8000-00805f9b34fb");

    auto manufacturerNameStringChar = SimpleBLE::BluetoothUUID("00002a29-0000-1000-8000-00805f9b34fb");
    auto serialNumberStringChar = SimpleBLE::BluetoothUUID("00002a25-0000-1000-8000-00805f9b34fb");

    SimpleBLE::ByteArray manufacturerNameData = movSenseDevice.read(deviceInformationService, manufacturerNameStringChar);
    SimpleBLE::ByteArray serialNumberData = movSenseDevice.read(deviceInformationService, serialNumberStringChar);

    std::cout << std::endl;
    std::cout << "manufacturer: " << (std::string)manufacturerNameData << std::endl;

    movSenseDevice.disconnect();
}