FROM mylesagray/tensorflow-serving:r1.15-cpu-opt as serving_base

# Copy the built anpr model
COPY models/anpr/ /models/anpr/

# Copy in the config files for local or remote model pulls
COPY configs/ /configs/