import ora from 'ora';

export function createSpinner(text) {
  return ora({
    text,
    color: 'cyan',
    spinner: 'dots12',
  });
}

export async function withSpinner(text, fn) {
  const spinner = createSpinner(text);
  spinner.start();
  try {
    const result = await fn();
    spinner.succeed();
    return result;
  } catch (err) {
    spinner.fail();
    throw err;
  }
}
