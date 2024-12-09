import 'package:nfc_manager/nfc_manager.dart';
import 'package:smart_tank_app/token.dart';

class NfcController {
  late bool isAvailable;
  late NfcManager instance;
  final Token token;

  NfcController(this.token);

  Future<bool> checkAvailability() async {
    isAvailable = await NfcManager.instance.isAvailable();
    instance = NfcManager.instance;
    return isAvailable;
  }

  Future<void> startSession(Function(bool) onWriteComplete) async {
    await instance.startSession(
      onDiscovered: (NfcTag tag) async {
        await onDetect(tag, onWriteComplete);
      },
    );
  }

  Future<void> onDetect(NfcTag tag, Function(bool) onWriteComplete) async {
    print('NFC tag detected');
    print(tag.data);
    //TODO: Also make sure to save any cup information and remove other tokens from the cup
    try{
      //Write token id to the NFC tag, in overwrite mode
      NdefMessage message = NdefMessage([
        NdefRecord.createText(token.id.toString().padLeft(4, '0')),
      ]);

      
      await Ndef.from(tag)?.write(message);

      //read to confirm
      // Read to confirm
      NdefMessage? readMessage = await Ndef.from(tag)?.read();
      if (readMessage != null) {
        String readToken = String.fromCharCodes(readMessage.records[0].payload).substring(3);
        print('Message read: $readToken');
      } else {
        print('Failed to read message from NFC tag');
        return onWriteComplete(false);
      }

      // check if they match
      if (readMessage != null &&
        readMessage.records.isNotEmpty &&
        readMessage.records[0].payload.length == message.records[0].payload.length &&
        readMessage.records[0].payload.every((element) => message.records[0].payload.contains(element)))
        {
        print('Token written to NFC tag successfully');
        //TODO: update token status on the server
        onWriteComplete(true);
      } else {
        print('Failed to write token to NFC tag');
        onWriteComplete(false);
      }
    } 
    catch (e) {
      print('Failed to write token to NFC tag');
      print(e);
      onWriteComplete(false);
    }
  }

  Future<void> stopSession() async {
    await instance.stopSession();
  }
}