package xyz.quoridouble.api.aspects;

import java.util.Arrays;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.AfterThrowing;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Aspect
@Component
public class LogAspect {
  @Pointcut("within(com.quoridouble.api.controllers..*)" + "||"
      + "@annotation(com.quoridouble.api.annotations.Logger)")
  public void pointcut() {
  }

  @Around("pointcut()")
  public Object around(ProceedingJoinPoint joinPoint) throws Throwable {
    log.info(joinPoint.getSignature().toShortString());

    Arrays.stream(joinPoint.getArgs())
        .map(Object::toString)
        .forEach(log::debug);

    Object returnValue = joinPoint.proceed();

    if (returnValue != null) {
      if (returnValue instanceof ResponseEntity) {
        ResponseEntity<?> response = (ResponseEntity<?>) returnValue;
        if (response.getStatusCode().is2xxSuccessful() || response.getStatusCode().is3xxRedirection())
          log.info(String.format("<%s, %s>", response.getStatusCode().toString(), response.getBody()));
        else if (response.getStatusCode().is4xxClientError() || response.getStatusCode().is5xxServerError())
          log.error(String.format("<%s, %s>", response.getStatusCode().toString(), response.getBody()));
      } else {
        log.debug(returnValue.toString());
      }
    }

    return returnValue;
  }

  @AfterThrowing(pointcut = "pointcut()", throwing = "e")
  public void afterThrowing(JoinPoint joinPoint, Throwable e) {
    log.error(joinPoint.getSignature().toShortString());
    log.error(e.getMessage(), e);
  }
}
