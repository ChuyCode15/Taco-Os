package com.jmcsoft.taco_os.config;

import com.jmcsoft.taco_os.services.JwtService;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;

@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtService jwtService;

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {

        String header = request.getHeader("Authorization");

        if (header != null && header.startsWith("Bearer ")) {
            String token = header.substring(7);

            try {
                var jwt = jwtService.validarToken(token);

                String idUsuario = jwtService.extraerIdUsuario(jwt);
                String rol = jwtService.extraerRol(jwt);
                String nickname = jwtService.extraerNickname(jwt);

                String authorityRole = rol.startsWith("master_") ? "MASTER" : rol.toUpperCase();
                var authorities = List.of(new SimpleGrantedAuthority("ROLE_" + authorityRole));

                var authentication = new UsernamePasswordAuthenticationToken(
                        idUsuario, null, authorities
                );

                SecurityContextHolder.getContext().setAuthentication(authentication);

                request.setAttribute("idUsuario", idUsuario);
                request.setAttribute("rol", rol);
                request.setAttribute("nickname", nickname);

            } catch (Exception e) {
                SecurityContextHolder.clearContext();
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.setContentType("application/json");
                response.getWriter().write("{\"codigo\":\"TOKEN_INVALIDO\",\"mensaje\":\"Token inválido o expirado\"}");
                return;
            }
        }

        filterChain.doFilter(request, response);
    }
}
