package xyz.quoridouble.api.configs;

import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;
import org.springframework.core.env.Profiles;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import lombok.RequiredArgsConstructor;

@Configuration
@RequiredArgsConstructor
public class CorsConfig implements WebMvcConfigurer {
	private final Environment environment;

	@Override
	public void addCorsMappings(CorsRegistry registry) {
		registry.addMapping("/**")
				.allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
				.allowCredentials(true);

		if (environment.acceptsProfiles(Profiles.of("local", "dev"))) {
			registry.addMapping("/**").allowedOrigins("*");
		}

		if (environment.acceptsProfiles(Profiles.of("prod"))) {
			registry.addMapping("/**").allowedOrigins(environment.getProperty("app.quoridouble.xyz"));
		}
	}
}
