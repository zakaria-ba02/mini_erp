export enum UserRole {
  Admin = 'admin',
  Customer = 'customer',
}

export interface JwtPayload {
  uid: string;
  role: UserRole;
  customerId?: string;
}
