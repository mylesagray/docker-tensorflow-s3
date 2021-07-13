FROM mylesagray/tensorflow-serving:r1.15-cpu-opt as serving_base

# Add Tini to do SIGTERM handling
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

# Copy the built anpr model
COPY models/anpr/ /models/anpr/

# Copy in the config files for local or remote model pulls
COPY configs/ /configs/

ENTRYPOINT ["/tini", "--", "/usr/bin/tf_serving_entrypoint.sh"]