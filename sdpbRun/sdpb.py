import json
import os
import re
import subprocess as sp
import argparse
try:
    from mpmath import mp, mpf
except ImportError:
    print('Please install mpmath package')
    exit(1)


def compute(json_file: str, precision: int,
            hi_only: bool, fixed_coeff = [None]) -> None:
    with open(json_file, 'r') as f:
        json_data = json.load(f)

    pmp2sdp = f'mpirun\
            pmp2sdp\
            {precision}\
            {json_file}\
            sdpbIO/input'
    sdpb = f'mpirun\
            sdpb\
            --noFinalCheckpoint\
            --maxIterations=5000\
            --precision={precision}\
            --writeSolution="x,y,z"\
            -s sdpbIO/input'


    match = re.compile(r'primalObjective = .*;')
    matchReason = re.compile(r'terminateReason = ".*";')
    output = {'Hi': {}, 'Low': {}}


    # assuming data is initially written for the upper bound
    normup = [mpf(x) for x in json_data['normalization']]
    for v in fixed_coeff:
        for s in (1,) if hi_only else (-1,1):
            json_data['normalization'] = [str(s*x) for x in normup]
            if v is not None:
                json_data['objective'][2] = str(-v)
            with open(json_file, 'w') as f:
                json.dump(json_data, f)

            sp.run(pmp2sdp, shell=True)
            sp.run(sdpb, shell=True)

            with open('sdpbIO/input_out/out.txt', 'r') as f:
                text = f.read()
                r = -s*float(re.findall(match, text)[0][18:-1])
                reason = re.findall(matchReason, text)[0][19:-2]

            output['Hi' if s==1 else 'Low'][v] = r
            with open('output.json', 'w') as f:
                json.dump(output, f)
            with open('digest.txt', 'a') as f:
                f.write(f'{v}\t{s}\t{reason}\n')

            # extract the spectrum
            spectrum_file = 'sdpbIO/spectrum' + (
                '.json' if v is None else f'_{v}.json'
            )
            extract_spectrum(json_file, precision, spectrum_file)


def angles(json_file: str, precision: int, hi_only: bool) -> None:
    output = {'Hi': {}, 'Low': {}}

    # iterate over 'angles' t
    for t, f in ((float(re.findall(r'\d+\.\d*', f)[-1]),
                f) for f in os.listdir(json_file)):
        print(f'Bounding t={t}....', flush=True)
        compute(f'{json_file}/{f}', precision, hi_only)
        with open('output.json','r') as f:
            temp = json.load(f)
            output['Hi'][t] = temp['Hi']['null']
            if not hi_only:
                output['Low'][t] = temp['Low']['null']
        with open('output_angles.json', 'w') as f:
            json.dump(output, f)
        os.rename('sdpbIO/spectrum.json',
                  f'sdpbIO/spectrum_{t}.json')
        low_mass_couplings = extract_couplings(5)
        with open(f'sdpbIO/low_mass_couplings_{t}.json', 'w') as f:
            json.dump(low_mass_couplings, f)
        # we remove the checkpoint file to avoid poisoning the next bound
        for file in os.listdir('sdpbIO/input.ck'):
            os.remove(f'sdpbIO/input.ck/{file}')
        os.rmdir('sdpbIO/input.ck')

    os.rename('output_angles.json', 'output.json')


def extract_couplings(spin_max: int) -> list[str]:
    couplings = []
    for i in range(spin_max + 1):
        with open(f'sdpbIO/input_out/x_{i}.txt', 'r') as f:
            f.readline() # skip the heading
            couplings.append(f.readline().strip())
    return couplings


def extract_spectrum(json_file: str, precision: int, output: str) -> None:
    spectrum = f'mpirun\
                spectrum\
                --precision={precision}\
                --input={json_file}\
                --solution=sdpbIO/input_out\
                --threshold=1e-5\
                --output={output}'
    print(f'Extracting spectrum...', flush=True)
    sp.run(spectrum, shell=True)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('json_file', type=str)
    parser.add_argument('--precision', type=int,
            dest='precision', required=True)
    parser.add_argument('--fixed_coeff', type=str,
            dest='fixed_coeff', required=False)
    parser.add_argument('--angles', action='store_true')
    parser.add_argument('--hi_only', action='store_true')
    args = parser.parse_args()

    mp.prec = args.precision
    
    with open('digest.txt', 'w') as f:
        f.write('#fixed_coeff\t#sign\t#terminateReason\n')
    if args.angles:
        angles(args.json_file, args.precision, args.hi_only)
    else:
        fixed_coeff = [None] if args.fixed_coeff is None else\
                map(float, args.fixed_coeff.split(','))
        compute(args.json_file, args.precision, args.hi_only, fixed_coeff)


if __name__ == '__main__':
    main()
