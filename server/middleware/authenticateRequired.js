import { authenticate } from './authenticate.js';
import { HttpError } from './errorHandler.js';

export async function authenticateRequired(req, res, next) {
  await authenticate(req, res, (err) => {
    if (err) return next(err);
    if (!req.user) {
      return next(new HttpError(401, 'Sign in to continue'));
    }
    next();
  });
}
export default authenticateRequired;