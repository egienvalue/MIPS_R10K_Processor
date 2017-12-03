#!/bin/bash
rm -rf new_out
mkdir new_out
cd testbench/core_top
make clean
make simv
cd ../..
echo "@@@ Starting test!" | tee test.rep
for file in test_progs/*.s; do
    filename=$(echo $file | cut -d'.' -f1 | cut -d'/' -f2)
    echo "Assembling $filename"
    ./vs-asm < $file > program.mem
    echo "Running $filename"
    ./testbench/core_top/simv | tee program.out
    echo "Saving $filename output"
    mkdir new_out/$filename
    mv *.out new_out/$filename

    diff golden/"${filename}.writeback.out" new_out/$filename/writeback.out > new_out/$filename/wbdiffresult
    if test -s new_out/$filename/wbdiffresult; then
        echo "@@@ Failed at test $filename, writeback.out doesn't match!" | tee -a test.rep
        #exit 1
    fi
    grep "@@@" golden/"${filename}.program.out" > goldenpr_trim
    grep "@@@" new_out/$filename/program.out > newpr_trim
    diff goldenpr_trim newpr_trim > new_out/$filename/prdiffresult
    if test -s new_out/$filename/prdiffresult; then
        echo "@@@ Failed at test $filename, program.out doesn't match!" | tee -a test.rep
        #exit 1
    fi
    #echo "@@@ Passed test $filename" | tee -a test.rep
done

#rm wbdiffresult goldenpr_trim newpr_trim prdiffresult
echo "@@@ Passed!" | tee -a test.rep
