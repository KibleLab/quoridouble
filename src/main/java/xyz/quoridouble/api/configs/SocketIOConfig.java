package xyz.quoridouble.api.configs;

import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.ApplicationListener;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.event.ContextClosedEvent;

import com.corundumstudio.socketio.SocketIONamespace;
import com.corundumstudio.socketio.SocketIOServer;

import lombok.RequiredArgsConstructor;
import xyz.quoridouble.api.services.game.GameSessionService;

@Configuration
@RequiredArgsConstructor
public class SocketIOConfig implements ApplicationListener<ContextClosedEvent> {
  @Value("${socket.port}")
  private Integer port;

  private SocketIOServer server;

  @Bean(initMethod = "start")
  public SocketIOServer socketIOServer() {
    com.corundumstudio.socketio.Configuration config = new com.corundumstudio.socketio.Configuration();
    config.setHostname("localhost");
    config.setPort(port);
    config.setContext("/socket.io");

    // 추가 설정
    config.setAllowCustomRequests(true);
    config.setPingTimeout(60000);
    config.setPingInterval(25000);
    config.setOrigin("*");

    server = new SocketIOServer(config);
    return server;
  }

  @Bean
  public SocketIONamespace roomNamespace(SocketIOServer server) {
    SocketIONamespace namespace = server.addNamespace("/room");

    // 네임스페이스 연결 로깅 추가
    namespace.addConnectListener(client -> {
      System.out.println("Client connected to /room namespace: " + client.getSessionId());
    });

    return namespace;
  }

  @Bean
  public CommandLineRunner socketIOServerInitializer(
      SocketIOServer server,
      SocketIONamespace roomNamespace,
      GameSessionService gameSessionService) {
    return args -> {
      System.out.println("Initializing Socket.IO server...");

      roomNamespace.addConnectListener(client -> {
        System.out.println("User connected to room: " + client.getSessionId());
        gameSessionService.matchClients(client);
      });

      roomNamespace.addEventListener("gameData", Map.class, (client, data, ackRequest) -> {
        String roomId = client.get("roomId");
        System.out.println("Received gameData from: " + client.getSessionId() + " for room: " + roomId);

        Integer action = (Integer) data.get("action");
        System.out.println("Received action: " + action);

        if (roomId != null) {
          // 현재 클라이언트를 제외한 같은 방의 다른 클라이언트들에게만 이벤트 전송
          roomNamespace.getRoomOperations(roomId)
              .getClients()
              .stream()
              .filter(c -> !c.getSessionId().equals(client.getSessionId())) // 현재 클라이언트 제외
              .forEach(c -> {
                c.sendEvent("gameData", Map.of("action", action));
              });
        }
      });

      roomNamespace.addDisconnectListener(client -> {
        System.out.println("User disconnected from room: " + client.getSessionId());
        gameSessionService.handleDisconnection(client);
      });

      System.out.println("Socket.IO server initialized successfully");
    };
  }

  @Override
  public void onApplicationEvent(ContextClosedEvent event) {
    if (server != null) {
      server.stop();
      try {
        Thread.sleep(2000);
      } catch (InterruptedException e) {
        Thread.currentThread().interrupt();
      }
    }
  }
}