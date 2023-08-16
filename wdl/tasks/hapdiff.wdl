version 1.0

task hapdiff_t {
  input {
    File ctgsPat
    File ctgsMat
    File reference
    File? vntrAnnotations
    String sample = "Sample"
    Int minSvSize = 25
    Int threads = 16
    Int memSizeGb = 50
      Int diskSizeGb = 50
      String dockerContainer = "registry-vpc.miracle.ac.cn/gznl/mkolmogo_hapdiff:0.8"
  }

  String trfString = if defined(vntrAnnotations) then "--tandem-repeats " else ""
  command <<<
    set -o pipefail
    set -e
    set -u
    set -o xtrace

    hapdiff.py --reference ~{reference} ~{trfString}~{vntrAnnotations} --pat ~{ctgsPat} --mat ~{ctgsMat} --out-dir hapdiff -t ~{threads} --sv-size ~{minSvSize} --sample ~{sample} 2>&1 | tee hapdiff.log
  >>>

  output {
    File hapdiffUnphasedVcf = "hapdiff/hapdiff_unphased.vcf.gz"
    File hapdiffPhasedVcf = "hapdiff/hapdiff_phased.vcf.gz"
    File hapdiffLog = "hapdiff.log"
  }

  runtime {
    preemptible: 2
    docker: dockerContainer
    cpu: threads
    memory: memSizeGb + " GB"
    disks: "local-disk " + diskSizeGb + " SSD"
  }
}
