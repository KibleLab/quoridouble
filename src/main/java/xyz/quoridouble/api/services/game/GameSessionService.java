package xyz.quoridouble.api.services.game;

import java.util.Map;

import org.springframework.stereotype.Service;

import com.corundumstudio.socketio.SocketIOClient;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class GameSessionService {
  private SocketIOClient waitingClient = null;

  public synchronized void matchClients(SocketIOClient client) {
    if (waitingClient != null) {
      String roomId = "room-" + waitingClient.getSessionId() + "-" + client.getSessionId();

      // 방 참가
      client.joinRoom(roomId);
      waitingClient.joinRoom(roomId);

      // roomId 저장
      client.set("roomId", roomId);
      waitingClient.set("roomId", roomId);

      // 게임 시작 알림
      int isFirst = (int) Math.floor(Math.random() * 2);
      client.sendEvent("startGame", Map.of("roomId", roomId, "isFirst", isFirst));
      waitingClient.sendEvent("startGame", Map.of("roomId", roomId, "isFirst", 1 - isFirst));

      waitingClient = null;
    } else {
      waitingClient = client;
      client.sendEvent("waiting", "Waiting for another player...");
    }
  }

  public synchronized void handleDisconnection(SocketIOClient client) {
    if (client.equals(waitingClient)) {
      waitingClient = null;
      return;
    }

    String roomId = client.get("roomId");
    if (roomId != null) {
      client.getNamespace().getRoomOperations(roomId)
          .getClients().stream()
          .filter(c -> !c.getSessionId().equals(client.getSessionId()))
          .forEach(c -> c.sendEvent("opponentDisconnected",
              Map.of("message", "Your opponent has disconnected.")));
      client.leaveRoom(roomId);
    }
  }
}