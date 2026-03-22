import {
  registerDecorator,
  ValidationArguments,
  ValidationOptions,
} from 'class-validator';

export enum TransactionMutationScope {
  CURRENT = 'CURRENT',
  ALL = 'ALL',
}

export function IsOptionalDateString(validationOptions?: ValidationOptions) {
  return function (object: object, propertyName: string) {
    registerDecorator({
      name: 'isOptionalDateString',
      target: object.constructor,
      propertyName,
      options: validationOptions,
      validator: {
        validate(value: unknown) {
          if (value === undefined || value === null || value === '') {
            return true;
          }

          return typeof value === 'string' && !Number.isNaN(Date.parse(value));
        },
        defaultMessage(args: ValidationArguments) {
          return `${args.property} invalida.`;
        },
      },
    });
  };
}
