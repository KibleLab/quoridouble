package xyz.quoridouble.api.interceptors;

import org.slf4j.MDC;
import org.springframework.core.env.Environment;
import org.springframework.core.env.Profiles;
import org.springframework.lang.NonNull;
import org.springframework.lang.Nullable;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class MDCInterceptor implements HandlerInterceptor {
  private final Environment environment;

  @Override
  public boolean preHandle(
      @NonNull HttpServletRequest request, @NonNull HttpServletResponse response, @NonNull Object handler) {
    boolean isLocalProfile = environment.acceptsProfiles(Profiles.of("local"));

    // 요청 정보
    String method = request.getMethod(); // HTTP 메소드
    String requestURI = request.getRequestURI(); // 요청 URI
    String scheme = (isLocalProfile) ? request.getScheme().toUpperCase()
        : request.getHeader("X-Forwarded-Proto").toUpperCase(); // 프로토콜(http/https)
    String remoteAddr = (isLocalProfile) ? request.getRemoteAddr() : request.getHeader("X-Real-IP"); // 클라이언트 IP
    String protocol = request.getProtocol(); // HTTP 버전
    String userAgent = request.getHeader("User-Agent"); // 사용자 에이전트

    // MDC 설정
    MDC.put("method", method);
    MDC.put("requestURI", requestURI);
    MDC.put("scheme", scheme);
    MDC.put("remoteAddr", remoteAddr);
    MDC.put("protocol", protocol);
    MDC.put("userAgent", userAgent);

    return true;
  }

  @Override
  public void afterCompletion(
      @NonNull HttpServletRequest request, @NonNull HttpServletResponse response, @NonNull Object handler,
      @Nullable Exception ex) {
    MDC.remove("method");
    MDC.remove("requestURI");
    MDC.remove("scheme");
    MDC.remove("remoteAddr");
    MDC.remove("protocol");
    MDC.remove("userAgent");
    MDC.clear();
  }
}
