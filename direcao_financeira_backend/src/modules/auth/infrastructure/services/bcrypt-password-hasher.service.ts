import { Injectable } from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { PasswordHasher } from '../../domain/services/password-hasher';

@Injectable()
export class BcryptPasswordHasherService implements PasswordHasher {
  hash(value: string) {
    return bcrypt.hash(value, 10);
  }

  compare(value: string, hashedValue: string) {
    return bcrypt.compare(value, hashedValue);
  }
}
