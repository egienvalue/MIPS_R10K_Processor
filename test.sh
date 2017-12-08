#!/bin/bash
rm -rf new_out
mkdir new_out
make clean
make syn_simv
echo "@@@ Starting test!" | tee test_progs.rep
for file in test_progs/*.s; do
    filename=$(echo $file | cut -d'.' -f1 | cut -d'/' -f2)
    echo "Assembling $filename"
    ./vs-asm < $file > program.mem
    echo "Running $filename"
    ./syn_simv | tee program.out
    echo "Saving $filename output"
    mkdir ./new_out/$filename
    mv *.out ./new_out/$filename
	

    diff golden/"${filename}.writeback.out" new_out/$filename/writeback.out > new_out/$filename/wbdiffresult
    if test -s new_out/$filename/wbdiffresult; then
        echo "@@@ Failed at test $filename, writeback.out doesn't match!" | tee -a test_progs.rep
        #exit 1
    fi
    grep "@@@" golden/"${filename}.program.out" > goldenpr_trim
    grep "@@@" new_out/$filename/program.out > newpr_trim
    diff goldenpr_trim newpr_trim > new_out/$filename/prdiffresult
    if test -s new_out/$filename/prdiffresult; then
        echo "@@@ Failed at test $filename, program.out doesn't match!" | tee -a test_progs.rep
        #exit 1
    fi
    #echo "@@@ Passed test $filename" | tee -a test_progs.rep
done

#rm wbdiffresult goldenpr_trim newpr_trim prdiffresult
echo "@@@ Passed!" | tee -a test_progs.rep

rm -rf new_out
mkdir new_out
make clean
make syn_simv
echo "@@@ Starting test!" | tee decaf_test.rep
for file in decaf_test/*.s; do
    filename=$(echo $file | cut -d'.' -f1 | cut -d'/' -f2)
    echo "Assembling $filename"
    ./vs-asm < $file > program.mem
    echo "Running $filename"
    ./syn_simv | tee program.out
    echo "Saving $filename output"
    mkdir ./new_out/$filename
    mv *.out ./new_out/$filename

    diff decaf_golden/"${filename}.writeback.out" new_out/$filename/writeback.out > new_out/$filename/wbdiffresult
    if test -s new_out/$filename/wbdiffresult; then
        echo "@@@ Failed at test $filename, writeback.out doesn't match!" | tee -a decaf_test.rep
        #exit 1
    fi
    grep "@@@" decaf_golden/"${filename}.program.out" > goldenpr_trim
    grep "@@@" new_out/$filename/program.out > newpr_trim
    diff goldenpr_trim newpr_trim > new_out/$filename/prdiffresult
    if test -s new_out/$filename/prdiffresult; then
        echo "@@@ Failed at test $filename, program.out doesn't match!" | tee -a decaf_test.rep
        #exit 1
    fi
    #echo "@@@ Passed test $filename" | tee -a decaf_test.rep
done

#rm wbdiffresult goldenpr_trim newpr_trim prdiffresult
echo "@@@ Passed!" | tee -a decaf_test.rep

rm -rf new_out
mkdir new_out
make clean
make syn_simv
echo "@@@ Starting test!" | tee hidden_test.rep
for file in hidden_test/*.s; do
    filename=$(echo $file | cut -d'.' -f1 | cut -d'/' -f2)
    echo "Assembling $filename"
    ./vs-asm < $file > program.mem
    echo "Running $filename"
    ./syn_simv | tee program.out
    echo "Saving $filename output"
    mkdir ./new_out/$filename
    mv *.out ./new_out/$filename

    diff hidden_golden/"${filename}.writeback.out" new_out/$filename/writeback.out > new_out/$filename/wbdiffresult
    if test -s new_out/$filename/wbdiffresult; then
        echo "@@@ Failed at test $filename, writeback.out doesn't match!" | tee -a hidden_test.rep
        #exit 1
    fi
    grep "@@@" hidden_golden/"${filename}.program.out" > goldenpr_trim
    grep "@@@" new_out/$filename/program.out > newpr_trim
    diff goldenpr_trim newpr_trim > new_out/$filename/prdiffresult
    if test -s new_out/$filename/prdiffresult; then
        echo "@@@ Failed at test $filename, program.out doesn't match!" | tee -a hidden_test.rep
        #exit 1
    fi
    #echo "@@@ Passed test $filename" | tee -a hidden_test.rep
done

#rm wbdiffresult goldenpr_trim newpr_trim prdiffresult
echo "@@@ Passed!" | tee -a hidden_test.rep


