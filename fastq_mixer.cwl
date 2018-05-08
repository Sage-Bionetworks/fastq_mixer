#!/usr/bin/env cwl-runner
#
# Authors: Andrew Lamb

cwlVersion: v1.0
class: CommandLineTool
baseCommand: [Rscript, /usr/local/bin/fastq_mixer.R]

doc: "run fastq mixer"

requirements:
- class: InlineJavascriptRequirement

hints:
  DockerRequirement:
    dockerPull: fastq_mixer

inputs:

  fastq_files_p1:
    type:
      type: array
      items: File
    inputBinding:
      prefix: --fastq_files_p1
    
  fastq_files_p2:
    type:
      type: array
      items: File
    inputBinding:
      prefix: --fastq_files_p2
      
  sample_fractions:
    type:
      type: array
      items: float
    inputBinding:
      prefix: --sample_fractions

  seed:
    type: ["null", int]
    inputBinding:
      prefix: --seed

  output_prefix:
    type: string
    default: "result"
    inputBinding:
      prefix: --output_prefix

outputs:

  output_file1:
    type: File
    outputBinding:
      glob: $(inputs.output_prefix + "_p1.fastq")
      
  output_file2:
    type: File
    outputBinding:
      glob: $(inputs.output_prefix + "_p2.fastq")
