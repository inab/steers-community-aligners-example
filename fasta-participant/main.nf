#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

inputs = file(params.inputs)
database = file(params.database)
outdir = file(params.output_dir)
// result = outdir.mkdirs()
// println result ? "Created directory $outdir" : "Cannot create output directory: $outdir"

process fasta {
    publishDir "${outdir}", saveAs: { filename -> (destsubdir!='' ? "${destsubdir}/" : '') + filename.minus('resdir/') }
    container "quay.io/biocontainers/fasta3:36.3.8i--h7b50bb2_2"

    input:
	path an_input
    path database
    val destsubdir

    output:
	path "resdir/**" , emit: fasta_output


    shell:
    """
    mkdir -p "resdir/${destsubdir}"
    fasta36 -p -O "resdir/${destsubdir}/$(basename "${an_input}")_result.txt" "${an_input}" "${database}"
    """
}

workflow {
    main:
        // We are telling we want the result in this specific subdirectory
        // of the outdir
        // When empty string is no subdir
        fasta_input_ch = Channel.of(inputs)
        fasta_p = fasta(fasta_input_ch, database, '')

    // This sentence only makes sense enabling output
    publish:
        fasta_p.fasta_output >> "./"

}

// nextflow.preview.output = true
// 
// output {
// 	directory "${params.output_dir}"
//     mode "link"
// }
