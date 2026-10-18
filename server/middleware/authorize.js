import { HttpError } from './errorHandler.js';

export function authorize(...roles) {
  return (req, _res, next) => {
    if (!req.user) {
      return next(new HttpError(401, 'Authentication required'));
    }
    if (!roles.includes(req.user.role)) {
      return next(new HttpError(403, `This area is for ${roles.join(' or ')} only`));
    }
    next();
  };
}
export default authorize;
