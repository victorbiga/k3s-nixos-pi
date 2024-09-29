{ pkgs, role, ... }:

{
  services.k3s = {
    role = role;

    # Hardcoded server address for agents
    serverAddr = if role == "agent" then "https://10.0.0.21:6443" else "";

    # Include additional flags conditionally based on the role
    extraFlags = if role == "server" then [ "--disable=traefik" ] else [];
  };
}
