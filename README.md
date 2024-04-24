# cellcrypt

CellCrypt is a research tool for finding and analyzing cryptographic misuse in cellular cores. CellCrypt itself is written in python, and serves as a wrapper around CodeQL. Queries contained within CellCrypt are executed to extract relevant information from compiled databases, and said data is then processed by CellCrypt and output as results. 

CellCrypt is a result of our work on our paper "Examining Randomness and Cryptographic Failures in Open-Source Cellular Cores", published at CODASPY '24. A link to the paper will be added once the publication is finalized. We are uploading CellCrypt here for archival and transparency, and to advocate and support open-sourcing research artifacts.

## Setup

### CodeQL CLI

CellCrypt uses CodeQL as the analysis engine. The CodeQL libraries used at the time of research are included as a submodule pointing to the relevant commit. However, the CodeQL binary must be downloaded directly.

1. Download the CodeQL CLI binary from Github at https://github.com/github/codeql-cli-binaries/releases
2. Extract the downloaded file to codeql-home/ in the CellCrypt project
3. Copy `codeql-home/` to `~/.local/`
4. Add the extracted files to $PATH
5. Test in the CLI using `codeql -v`

Alternatively, follow the instructions at https://docs.github.com/en/code-security/codeql-cli/getting-started-with-the-codeql-cli/setting-up-the-codeql-cli. If choosing this method and you wish to use the included libraries, copy `./codeql-home/codeql-repo/` at the appropriate step rather than downloading as instructed.

### Python

1. Install Python3 through your package manager or from https://www.python.org/ 
2. Make sure pip is installed: `python -m ensurepip`
3. Run `pip install -r requirements.txt` in the CellCrypt project directory

### Recreating Experiment from CellCrypt Paper

| Core  | Version   |  Commit  |
| :----- | :---------: | :--------: |
|Free5GC| 3.0.2| [f8a6e7c](https://github.com/free5gc/free5gc/tree/f8a6e7ccdae72d311ef3c167d6f41ab187e4aa3b) |
| SD-Core | 1.3.0 | [amf](https://github.com/omec-project/amf/tree/a4759db),[nrf](https://github.com/omec-project/nrf/tree/b747b98),[smf](https://github.com/omec-project/smf/tree/13e567121e6f65453b6d17093b235fb002c0800d),[ausf](https://github.com/omec-project/ausf/tree/c84dff4), [nssf](https://github.com/omec-project/nssf/tree/4e5aef3),[pcf](https://github.com/omec-project/pcf/tree/bcbdeb0),[udr](https://github.com/omec-project/udr/tree/35eb7b7),[udm](https://github.com/udm/tree/6956659)|
|Open5GS | 2.5.6 | [3531166](https://github.com/open5gs/open5gs/tree/3531166) |
| OpenAirInterface CN5G | 1.4.0 | [2ff64a2](https://gitlab.eurecom.fr/oai/cn5g/oai-cn5g-fed/-/tree/2ff64a29bff7c302f8cfe27ccd3f6dcd86097ed9) |
|OpenAirInterface EPC | 1.2.0 | [2dd9a93](https://github.com/OPENAIRINTERFACE/openair-epc-fed/tree/2dd9a93c591512208dbd0009c9de59ee806b145a) |
| NextEPC | 1.0.1 | [c51673c](https://github.com/nextepc/nextepc/tree/c51673cf714d46285b3a7e41b79c57deeaf98638)|
|srsRAN | 23.04.1 |[fa56836](https://github.com/srsran/srsRAN_4G/tree/fa56836b14dc6ad7ce0c3484a1944ebe2cdbe63b)|

The table above lists the codebase versions and commits used in our experiments. 

1. For __SD-Core__, clone all tagged repos into a folder called `sd-core/`. 
2. For OpenAirInterface EPC, follow the instructions in the repo README to gather all required files. It needs some files from Magma MME.
3. For all other cores, download the repos at specified commits. Make sure to initialize and update all submodules.

After these steps, you should have each core inside a top-level folder named after the core itself. Place each folder inside `docker_containers` and run the DockerFiles to build the CodeQL databases.

__Note__: Free5GC, SD-Core, Open5GS, and OAI-5G DockerFiles are currently under maintenance and missing from the repo. They will be added ASAP. In the meantime, run the scripts found in `scripts/` to build those cores and extract the databases.

### Running Queries

1. Make sure all databases follow the directory structure specified in `run.py`. The previous instructions should ensure this.
2. Execute `python run.py`


For additional information, run `python run.py -h`

For any questions, feel free to create and issue or reach out to `kvenglis@ncsu.edu`.