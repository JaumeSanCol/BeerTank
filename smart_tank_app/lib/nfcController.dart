import 'package:nfc_manager/nfc_manager.dart';
import 'package:smart_tank_app/token.dart';

class NfcController {
  late bool isAvailable;
  late NfcManager instance;
  final Token token;
  late bool wasWriteSuccessful;

  NfcController(this.token);

  Future<bool> checkAvailability() async {
    isAvailable = await NfcManager.instance.isAvailable();
    instance = NfcManager.instance;
    return isAvailable;
  }

  Future<void> startSession() async {
    await instance.startSession(
      onDiscovered: onDetect,
    );
  }

  Future<void> onDetect(NfcTag tag) async {
    print('NFC tag detected');
    print(tag.data);
    try{
      //Write token id to the NFC tag, in overwrite mode
      NdefMessage message = NdefMessage([
        NdefRecord.createText(token.id.toString()),
      ]);
      
      await Ndef.from(tag)?.write(message);

      //read to confirm
      NdefMessage? readMessage = await Ndef.from(tag)?.read();
      print("message written to the tag:");
      print(readMessage);

      // check if they match
      if (readMessage == message) {
        print('Token written to NFC tag successfully');
      } else {
        print('Failed to write token to NFC tag');
      }
      wasWriteSuccessful = true;
    } 
    catch (e) {
      print('Failed to write token to NFC tag');
      print(e);
      wasWriteSuccessful = false;
    }
  }

  Future<void> stopSession() async {
    await instance.stopSession();
  }
}