version 1.0

task pcat_unphased_batch {
    input {
        Array[File]+ single_sample_vcf
    }

    command <<<
        set -x -e -o pipefail
        mkdir output
        for input in ~{sep=" " single_sample_vcf}; do
            file_prefix=$( basename $input ".vcf.gz")
            time /pharmcat/pharmcat_pipeline ${input} -0 -G -o output
            rm output/*.html
        done
    >>>

    output {
        Array[File] preprocessed_vcf = glob("output/*.preprocessed.vcf*")
        Array[File] matcher_json = glob("output/*.match.json")
        Array[File] phenotyper_json = glob("output/*.phenotype.json")
    }

    runtime {
        docker: "pgkb/pharmcat"
        memory: "16 GB"
        cpu: 4
    }

    parameter_meta {
        single_sample_vcf: {
            description: "unphased, single-sample vcf",
            patterns: ["*.vcf.gz"],
            stream: true
        }
    }
}

workflow PharmCATWorkflow {
    input {
        Array[File]+ single_sample_vcf
    }

    call pcat_unphased_batch { 
        input: 
        single_sample_vcf = single_sample_vcf,
    }
}

