import { Component, signal } from '@angular/core';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatButtonModule } from '@angular/material/button';
import { AngularSplitModule } from 'angular-split';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [MatToolbarModule, MatButtonModule, AngularSplitModule],
  templateUrl: './app.component.html',
  styleUrl: './app.component.scss'
})
export class AppComponent {
  title = 'JSONSchema Validator';
  
  // Placeholder for validation - actual implementation in Story 3.4
  isValidating = signal<boolean>(false);
  
  onValidate(): void {
    console.log('Validate button clicked - implementation in Story 3.4');
  }
}
