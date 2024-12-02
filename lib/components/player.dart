import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:just_audio/just_audio.dart';

void player() async{
  final player = AudioPlayer();         
  final String backendUrl = dotenv.env['BE_URL'] ?? '';         
  final duration = await player.setUrl('$backendUrl/play?itemId=26c8c6e021d8c682eca8e273fb487f65');
  player.play();
}