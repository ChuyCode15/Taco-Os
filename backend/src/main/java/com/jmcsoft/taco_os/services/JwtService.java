package com.jmcsoft.taco_os.services;

import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import com.auth0.jwt.exceptions.JWTVerificationException;
import com.auth0.jwt.interfaces.DecodedJWT;
import com.auth0.jwt.interfaces.JWTVerifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.Date;

@Service
public class JwtService {

    @Value("${jwt.secret}")
    private String secret;

    @Value("${jwt.expiration-ms}")
    private long expirationMs;

    public String generarToken(String idUsuario, String idGoogle, String rol, String nickname) {
        Algorithm algorithm = Algorithm.HMAC256(secret);
        return JWT.create()
                .withSubject(idUsuario)
                .withClaim("idGoogle", idGoogle)
                .withClaim("rol", rol)
                .withClaim("nickname", nickname != null ? nickname : "")
                .withIssuedAt(new Date())
                .withExpiresAt(new Date(System.currentTimeMillis() + expirationMs))
                .sign(algorithm);
    }

    public DecodedJWT validarToken(String token) {
        Algorithm algorithm = Algorithm.HMAC256(secret);
        JWTVerifier verifier = JWT.require(algorithm).build();
        return verifier.verify(token);
    }

    public String extraerIdUsuario(DecodedJWT jwt) {
        return jwt.getSubject();
    }

    public String extraerRol(DecodedJWT jwt) {
        return jwt.getClaim("rol").asString();
    }

    public String extraerIdGoogle(DecodedJWT jwt) {
        return jwt.getClaim("idGoogle").asString();
    }

    public String extraerNickname(DecodedJWT jwt) {
        return jwt.getClaim("nickname").asString();
    }

    public boolean esTokenExpirado(DecodedJWT jwt) {
        return jwt.getExpiresAt().before(new Date());
    }

    public String refrescarToken(String token) {
        var decoded = validarToken(token);
        if (esTokenExpirado(decoded)) {
            throw new com.jmcsoft.taco_os.common.exception.NoAutorizadoException(
                    "Token expirado, inicia sesión nuevamente",
                    "JwtService.refrescarToken"
            );
        }
        return generarToken(
                decoded.getSubject(),
                decoded.getClaim("idGoogle").asString(),
                decoded.getClaim("rol").asString(),
                decoded.getClaim("nickname").asString()
        );
    }
}
