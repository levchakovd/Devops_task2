import json

def test_diff_outputs_json_with_expected():
    """
    Test that result is the same
    """
    failed = False

    try:
        # Save the output of both commands to files
        run_shell_test(f'cat out2.json | ./jq -e . > 1.test')
        run_shell_test('cat output.json | ./jq -e . > 2.test')

        # Compare the contents of the two test files
        diff_result = run_shell_test('diff 1.test 2.test', capture_output=True)
        if diff_result.returncode != 0:
            print("Difference in test files:")
            print(diff_result.stdout.decode('utf-8'))
            failed = True

            # Save the differences to diff.json
            differences = {
                "diff_output": diff_result.stdout.decode('utf-8')
            }
            with open('diff.json', 'w') as diff_file:
                json.dump(differences, diff_file)

    except CalledProcessError as e:
        failed = True
        result = e.output
        code = e.returncode

    if failed:
        pytest.fail(f"Return code: {code} Script output: {result}")
