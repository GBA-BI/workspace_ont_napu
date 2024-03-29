version 1.0

task modbam2bed {
    input {
        File haplotaggedBam
        File haplotaggedBamBai
        File ref
        String sample_name
        String ref_name = "ref"
        String modType = "5mC"    
        String out_type_filter = "cpg"
        String? extraArgs
        Int memSizeGB = 64
        Int threadCount = 16
        Int diskSizeGB = round(size(haplotaggedBam, 'G')) + round(size(ref, 'G')) + 10
        String dockerImage = "registry-vpc.miracle.ac.cn/gznl/meredith705_ont_methyl:latest"
        File? resourceLogScript
    }

    parameter_meta {
        haplotaggedBam: "Guppy with Remora reads aligned to assembly. in BAM format."
        ref: "Assembly (reference) to that reads are aligned to."
        sample_name: "Sample name. Will be used in output bed file."
        ref_name: "Reference name. Will be used in output bed file."
        modType: "Modified base of interest, one of: 5mC (default), 5hmC, 5fC, 5caC, 5hmU, 5fU, 5caU, 6mA, 5oxoG, Xao."
        out_type_filter: " Output records filtered to these sites: cpg (default), chg, chh"
    }

    command <<<
        # exit when a command fails, fail with unset variables, print commands before execution
        set -eux -o pipefail
        set -o xtrace

        ## run a recurrent "top" in the background to monitor resource usage
        if [ ~{resourceLogScript} != "" ]
        then
            bash ~{resourceLogScript} 20 top.log &
        fi

        
        ## Pass optional arguments if extraArgs is set, if not just pass empty string
        if [ -z "~{extraArgs}" ]
        then
            EXTRA_ARGS=""
        else
            EXTRA_ARGS="~{extraArgs}"
        fi

        ln -s ~{haplotaggedBam} reads.bam
        ln -s ~{haplotaggedBamBai} reads.bam.bai
        
        for HP in 1 2; do
            modbam2bed \
                -e -m ~{modType} --~{out_type_filter} -t ~{threadCount} --haplotype ${HP} ${EXTRA_ARGS} \
                ~{ref} reads.bam | bgzip -c > ~{sample_name}.haplotagged.bam.hp${HP}.cpg.bed.gz
        done;
    >>>

        output {
            File hap1bedOut      = "~{sample_name}.haplotagged.bam.hp1.cpg.bed.gz"
            File hap2bedOut      = "~{sample_name}.haplotagged.bam.hp2.cpg.bed.gz"
            File? toplog = "top.log"
    }

    runtime {
        memory: memSizeGB + " GB"
        cpu: threadCount
        disks: "local-disk " + diskSizeGB + " SSD"
        docker: dockerImage
        preemptible: 2
    }
}
