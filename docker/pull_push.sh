tag_list=("google/deepvariant:cl508467184" "mkolmogo/card_harmonize_vcf:0.1" "quay.io/biocontainers/bcftools@sha256:95c212df20552fc74670d8f16d20099d9e76245eda6a1a6cfff4bd39e57be01b" "mkolmogo/card_minimap2:2.23" "quay.io/jmonlong/minimap2_samtools:v2.24_v1.16.1_pigz" "biocontainers/samtools@sha256:3ff48932a8c38322b0a33635957bc6372727014357b4224d420726da100f5470" "kishwars/pepper_deepvariant:r0.8" "quay.io/jmonlong/card_shasta@sha256:ce218dc133b2534f58f841bccd4b1d1d880c6ad62c1c321dd91bdd8d43e554f1" "quay.io/jmonlong/card_shasta@sha256:ce218dc133b2534f58f841bccd4b1d1d880c6ad62c1c321dd91bdd8d43e554f1" "mkolmogo/card_sniffles:2.0.3")
for tag in "${tag_list[@]}"; do
    echo "--------------"
    echo "[PULL] $tag"
    docker pull "$tag"
    echo "registry-vpc.miracle.ac.cn/gznl/${tag//\//_}"
    docker tag "$tag" "registry-vpc.miracle.ac.cn/gznl/${tag//\//_}"
    echo "[PUSH] $tag"
    docker push "registry-vpc.miracle.ac.cn/gznl/${tag//\//_}"
    echo "[FINISH] $tag"
    echo "--------------"
done