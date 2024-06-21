let
  rhousand = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB3QajOuMej5aFp0J+ixvZiS/LAKiqGFPQiE0CBH6fhp";
  root = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO/RjZ4o4z265/nTQtswrVCNEsg3eR5v9qXi8Qq84CKe";
  users = [rhousand root];

  system1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILGaoMvul1XuY+OWaGTYEAb6sXztxtja3lvQ7tfCF7qy";
  system2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILGaoMvul1XuY+OWaGTYEAb6sXztxtja3lvQ7tfCF7qy";
  systems = [system1 system2];
in {
  "secret1.age".publicKeys = users ++ systems;
  "secret2.age".publicKeys = users ++ systems;
}
