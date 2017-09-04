module resources.MeshRepository;

import resources.Mesh;
import resources.InstanceRepository;

alias MeshRepository = InstanceRepository!("Mesh", Scene);